"""
MongoDB access for the whole project.

One lazily created client is shared by every caller, because a `MongoClient`
already owns a connection pool and is thread safe - building a second one per
module just burns connections against the Atlas cluster.

Typical use::

    from recipe_ml.db import recipes, get_collection, get_db

    recipes().find_one({"Cuisine": "Indian"})   # the recipe collection
    get_collection("feedback").insert_one({})   # any other collection
    get_db().list_collection_names()

For a short lived script that should not leave a pool open::

    with mongo_client() as client:
        client[Config.MONGO_DB].recipes.count_documents({})
"""

from contextlib import contextmanager
from typing import Iterator, Optional

from pymongo import MongoClient
from pymongo.collection import Collection
from pymongo.database import Database
from pymongo.errors import PyMongoError

from .config import Config

_client: Optional[MongoClient] = None
_config = Config()


class DatabaseError(RuntimeError):
    """Raised when the database is missing or unreachable."""


def get_client(uri: Optional[str] = None) -> MongoClient:
    """
    The shared client. Created on first use so that importing this module
    never blocks on a network call.

    Passing `uri` bypasses the shared instance and returns a fresh client -
    the caller then owns it and is responsible for closing it.
    """
    if uri is not None:
        return _build_client(uri)

    global _client
    if _client is None:
        if not _config.MONGO_URI:
            raise DatabaseError(
                "MONGO_URI is not set - add it to the .env file at the project root."
            )
        _client = _build_client(_config.MONGO_URI)
    return _client


def _build_client(uri: str) -> MongoClient:
    return MongoClient(
        uri,
        # Fail fast with a clear error instead of hanging for 30s on a bad URI.
        serverSelectionTimeoutMS=10_000,
        connectTimeoutMS=10_000,
        retryWrites=True,
        tz_aware=True,
    )


def get_db(name: Optional[str] = None) -> Database:
    """The application database, or another one by name."""
    return get_client()[name or _config.MONGO_DB]


def get_collection(name: str, db_name: Optional[str] = None) -> Collection:
    """Any collection by name."""
    return get_db(db_name)[name]


def recipes() -> Collection:
    """The recipe collection - the one nearly every caller wants."""
    return get_collection(_config.RECIPE_COLLECTION)


def ping() -> bool:
    """True if the cluster answers. Used by the API health check."""
    try:
        get_client().admin.command("ping")
        return True
    except (PyMongoError, DatabaseError):
        return False


def close() -> None:
    """Close the shared client. Safe to call more than once."""
    global _client
    if _client is not None:
        _client.close()
        _client = None


@contextmanager
def mongo_client(uri: Optional[str] = None) -> Iterator[MongoClient]:
    """A client scoped to a `with` block, closed on exit."""
    client = _build_client(uri or _config.MONGO_URI) if (uri or _config.MONGO_URI) else None
    if client is None:
        raise DatabaseError("MONGO_URI is not set - add it to the .env file at the project root.")
    try:
        yield client
    finally:
        client.close()

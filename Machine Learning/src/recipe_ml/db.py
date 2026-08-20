"""MongoDB access for the whole project. One lazily created `MongoClient` is
shared by every caller - it already owns a thread safe connection pool."""

from typing import Optional

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
    """The shared client, created on first use. Passing `uri` returns a fresh
    client the caller owns and must close."""
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
        # fail fast instead of hanging 30s on a bad URI
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
    """The recipe collection."""
    return get_collection(_config.RECIPE_COLLECTION)


def ping() -> bool:
    """True if the cluster answers."""
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

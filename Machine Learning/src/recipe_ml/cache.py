"""Redis cache for recommendation results. One lazily created `Redis` is shared
by every caller - it already owns a connection pool. Every call degrades to a
miss when Redis is unreachable, so a broken cache never breaks a request."""

import json
import logging
from typing import Any, Optional

import redis

from .config import Config

KEY_PREFIX = "rec:"

logger = logging.getLogger(__name__)

_client: Optional[redis.Redis] = None
_config = Config()


def get_client() -> redis.Redis:
    """The shared client, created on first use."""
    global _client
    if _client is None:
        _client = redis.Redis.from_url(
            _config.REDIS_URL,
            decode_responses=True,
            # an unreachable cache must not hold up the request
            socket_connect_timeout=1,
            socket_timeout=1,
        )
    return _client


def get(key: str) -> Optional[Any]:
    try:
        value = get_client().get(key)
    except redis.RedisError as exc:
        logger.warning("cache read failed for %s: %s", key, exc)
        return None
    return json.loads(value) if value is not None else None


def set(key: str, value: Any) -> None:
    try:
        get_client().set(key, json.dumps(value), ex=_config.RECOMMENDATION_CACHE_TTL)
    except redis.RedisError as exc:
        logger.warning("cache write failed for %s: %s", key, exc)


def invalidate_recommendations() -> None:
    """Drop every cached recommendation. Called when a recipe joins the
    searchable corpus, which makes earlier results stale."""
    try:
        client = get_client()
        for key in client.scan_iter(match=f"{KEY_PREFIX}*", count=500):
            client.delete(key)
    except redis.RedisError as exc:
        logger.warning("cache invalidation failed: %s", exc)


def close() -> None:
    """Close the shared client. Safe to call more than once."""
    global _client
    if _client is not None:
        _client.close()
        _client = None

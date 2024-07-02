from flask_caching import Cache
from os import environ

# Create a cache instance with configuration but without the app instance.
cache = Cache(config={
    'CACHE_TYPE': 'FileSystemCache',
    'CACHE_DIR': 'cache',
    'CACHE_THRESHOLD': 150
})

def init_cache(app):
    """Attach cache to the Flask app."""
    cache.init_app(app)

def get_or_set_tickers():
    tickers = cache.get("tickers-store")
    
    if tickers is None:
        tickers = (environ.get("TICKERS") or "COIN").strip().split(",")
        cache.set("tickers-store", tickers)
        
    return tickers
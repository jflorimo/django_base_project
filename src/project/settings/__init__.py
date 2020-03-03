from .common import *
from .common import config_path


with open(config_path) as config:
    exec(config.read())


__version__ = "2"

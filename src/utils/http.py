import requests


HTTP_TIMEOUT = 30


def add_timeout(request_fun):
    def inner(*args, **kwargs):
        kwargs.setdefault("timeout", HTTP_TIMEOUT)
        return request_fun(*args, **kwargs)

    return inner


get = add_timeout(requests.get)
post = add_timeout(requests.post)
put = add_timeout(requests.put)
delete = add_timeout(requests.delete)

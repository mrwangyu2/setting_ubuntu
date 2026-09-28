"""Mirror choices offered on the command line."""

# apt archive URI per mirror key.
APT_MIRRORS = {
    "aliyun": "http://mirrors.aliyun.com/ubuntu/",
    "tuna": "https://mirrors.tuna.tsinghua.edu.cn/ubuntu/",
    "ustc": "https://mirrors.ustc.edu.cn/ubuntu/",
    "cn": "http://cn.archive.ubuntu.com/ubuntu/",
    "official": "http://archive.ubuntu.com/ubuntu/",
}

# pypi mirror: (index-url, trusted-host or None)
PYPI_MIRRORS = {
    "aliyun": ("http://mirrors.aliyun.com/pypi/simple/", "mirrors.aliyun.com"),
    "tuna": ("https://pypi.tuna.tsinghua.edu.cn/simple", "pypi.tuna.tsinghua.edu.cn"),
    "ustc": ("https://mirrors.ustc.edu.cn/pypi/simple", "mirrors.ustc.edu.cn"),
    "official": ("https://pypi.org/simple", None),
}

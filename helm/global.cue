package helm


proxy: string
noProxy: string

_env: {
    http_proxy: proxy
    https_proxy: proxy
    no_proxy: noProxy
}
#!/bin/bash

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH}

if [ "x${HOME}" == "x" ]; then
    HOME=$1
fi

PIC_DIR="${HOME}/Pictures/bg"
BING_IMAGE_DOWNLOAD_URL_PREFIX='http://s.cn.bing.net'
BING_IMAGE_URL='https://cn.bing.com/HPImageArchive.aspx?n=10&format=js'
BING_IMAGE_URL2='https://cn.bing.com/HPImageArchive.aspx?n=10&format=js&ensearch=1'

mkdir -p "${PIC_DIR}"

fetch() {
    urls=$(curl "$1" 2>/dev/null | jq -r '.images[] | .url')

    for url in ${urls}; do
        local fn=$(echo ${url} | sed 's/.*[?|&]id=\([^&]*\).*/\1/g')
        wget "${BING_IMAGE_DOWNLOAD_URL_PREFIX}${url}" -O "${PIC_DIR}/${fn}"
    done
}

inarray() {
    local t=$1
    shift 1
    for it in "$@"; do
        if [ "${t}" == "${it}" ]; then
            echo 1
            return
        fi
    done
    echo 0
}

clean() {
    all=()
    fs=$(ls ${PIC_DIR})
    for f in ${fs}; do
        fp="${PIC_DIR}/${f}"
        h=$(md5 -q ${fp})
        r=$(inarray ${h} ${all[*]})
        if [ "${r}" -eq "1" ]; then
            $(rm -f "${fp}")
        else
            all[${#all[*]}]=${h}
        fi
    done
}

fetch ${BING_IMAGE_URL}
fetch ${BING_IMAGE_URL2}
clean


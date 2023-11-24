FROM ubuntu:22.04

# python intallation part is borrowed from official python docker image
# ensure local python is preferred over distribution python
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

ENV GPG_KEY A035C8C19219BA821ECEA86B64E628F8D684696D
ENV PYTHON_VERSION 3.11.6
# runtime dependencies + build tool (gcc and make)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    libbluetooth-dev \
    tk-dev \
    uuid-dev \
    gcc \
    make \
    wget \
    gnupg \
    ca-certificates \
    ; \
    apt-get remove python; \
    apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev; \
    rm -rf /var/lib/apt/lists/* \
    # intall python
    && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"; \
    wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc"; \
    GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$GPG_KEY"; \
    gpg --batch --verify python.tar.xz.asc python.tar.xz; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME" python.tar.xz.asc; \
    mkdir -p /usr/src/python; \
    tar --extract --directory /usr/src/python --strip-components=1 --file python.tar.xz; \
    rm python.tar.xz; \
    \
    cd /usr/src/python; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
    --build="$gnuArch" \
    --enable-loadable-sqlite-extensions \
    --enable-optimizations \
    --enable-option-checking=fatal \
    --enable-shared \
    --with-lto \
    --with-system-expat \
    --without-ensurepip \
    ; \
    nproc="$(nproc)"; \
    EXTRA_CFLAGS="$(dpkg-buildflags --get CFLAGS)"; \
    LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"; \
    make -j "$nproc" \
    "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
    "LDFLAGS=${LDFLAGS:-}" \
    "PROFILE_TASK=${PROFILE_TASK:-}" \
    ; \
    # https://github.com/docker-library/python/issues/784
    # prevent accidental usage of a system installed libpython of the same version
    rm python; \
    make -j "$nproc" \
    "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
    "LDFLAGS=${LDFLAGS:--Wl},-rpath='\$\$ORIGIN/../lib'" \
    "PROFILE_TASK=${PROFILE_TASK:-}" \
    python \
    ; \
    make install; \
    \
    # enable GDB to load debugging data: https://github.com/docker-library/python/pull/701
    bin="$(readlink -ve /usr/local/bin/python3)"; \
    dir="$(dirname "$bin")"; \
    mkdir -p "/usr/share/gdb/auto-load/$dir"; \
    cp -vL Tools/gdb/libpython.py "/usr/share/gdb/auto-load/$bin-gdb.py"; \
    \
    cd /; \
    rm -rf /usr/src/python; \
    \
    find /usr/local -depth \
    \( \
    \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
    -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \
    \) -exec rm -rf '{}' + \
    ; \
    \
    ldconfig; \
    \
    apt-get remove -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev gcc make;\
    \
    python3 --version \
    # make some useful symlinks that are expected to exist ("/usr/local/bin/python" and friends)
    && for src in idle3 pydoc3 python3 python3-config; do \
    dst="$(echo "$src" | tr -d 3)"; \
    [ -s "/usr/local/bin/$src" ]; \
    [ ! -e "/usr/local/bin/$dst" ]; \
    ln -svT "$src" "/usr/local/bin/$dst"; \
    done
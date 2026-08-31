## Builder stage: compile Erlang and install tools
FROM debian:stable AS builder
WORKDIR /root

# Install build dependencies and utilities
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential autoconf m4 libncurses-dev libwxgtk3.2-dev \
        libwxgtk-webview3.2-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev \
        unixodbc-dev xsltproc fop libxml2-utils openjdk-21-jdk curl ca-certificates git \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Build Erlang with kerl, install prebuilt rebar3, and install Elixir via kiex
SHELL ["/bin/bash", "-c"]
RUN curl -O https://raw.githubusercontent.com/kerl/kerl/master/kerl && \
    chmod a+x kerl && \
    ./kerl update releases && \
    ./kerl build 29.0.5 && \
    ./kerl install 29.0.5 /root/29.0.5 && \
    echo ". /root/29.0.5/activate" >> /root/.bashrc && \
    . /root/29.0.5/activate && \
    curl -L -o /usr/local/bin/rebar3 https://github.com/erlang/rebar3/releases/download/3.27.0/rebar3 && \
    chmod +x /usr/local/bin/rebar3 && \
    /usr/local/bin/rebar3 local install && \
    # Install kiex and Elixir
    curl -sSL https://raw.githubusercontent.com/taylor/kiex/master/install | bash -s && \
    echo 'test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"' >> /root/.bashrc && \
    source /root/.kiex/scripts/kiex && \
    kiex install 1.19.5 && \
    ELIXIR_VERSION=$(ls /root/.kiex/elixirs/ | grep '1.19.5' | head -1 | sed 's/elixir-//' | sed 's/\.env//') && \
    kiex use "$ELIXIR_VERSION" && \
    kiex default "$ELIXIR_VERSION"

# Clean builder (leave artifacts for copying)
RUN rm -rf /tmp/*

## Final runtime stage: copy only necessary runtime files
FROM debian:stable-slim
WORKDIR /root

# Install minimal runtime deps
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates curl python3-pip minicom vim git && \
    rm -rf /var/lib/apt/lists/*

# Copy Erlang, kiex (Elixir), and rebar3 from builder
COPY --from=builder /root/29.0.5 /root/29.0.5
COPY --from=builder /root/.kiex /root/.kiex
COPY --from=builder /usr/local/bin/rebar3 /usr/local/bin/rebar3

# Ensure rebar3 is executable and set PATH
RUN chmod +x /usr/local/bin/rebar3 && \
    echo 'test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"' >> /root/.bashrc

ENV PATH $PATH:/root/29.0.5/bin:/root/29.0.5/.cache/rebar3/bin

# Install esptool via pip (runtime)
RUN pip3 install --no-cache-dir --upgrade --break-system-packages esptool

# Verify installs
RUN rebar3 --version || true
RUN esptool version || true

SHELL ["/bin/bash", "-c"]
ENV PATH $PATH:/root/29.0.5/bin:/root/29.0.5/.cache/rebar3/bin

# AtomVM
WORKDIR /tools

## Clone atomvm_projects
RUN git clone https://github.com/biennguyen94/atomvm_projects.git
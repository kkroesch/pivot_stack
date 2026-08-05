FROM registry.fedoraproject.org/fedora:44

# Abhängigkeiten für AstroNvim (gcc, git, ripgrep, fd-find) und Basis-Tools
RUN dnf update -y && \
    dnf install -y curl git neovim fish gcc gcc-c++ python3 ripgrep fd-find tar visidata && \
    dnf clean all

# uv installieren
ENV UV_ROOT="/opt/uv"
ENV PATH="$UV_ROOT/bin:$PATH"
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv && \
    mv /root/.local/bin/uvx /usr/local/bin/uvx

# Starship installieren
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# AstroNvim Basis-Template klonen
RUN git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim && \
    rm -rf ~/.config/nvim/.git
RUN nvim --headless "+Lazy! sync" +qa


# Just installieren (via offiziellem Shell-Skript)
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# DuckDB CLI installieren (direktes Binary)
RUN curl -L -o duckdb.zip https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip && \
    unzip duckdb.zip -d /usr/local/bin && \
    rm duckdb.zip

# DVC global als isoliertes Tool via uv installieren
ENV PATH="/root/.local/bin:$PATH"
RUN uv tool install dvc && \
    uv tool install marimo

# Julia installieren (Offizielles Tarball)
# RUN curl -L https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.4-linux-x86_64.tar.gz | tar -xz -C /usr/local --strip-components=1

# Pluto.jl global für Julia vorab installieren
# RUN julia -e 'using Pkg; Pkg.add("Pluto")'

# Konfigurationen einrichten (starship und fish init)
COPY starship.toml /root/.config/starship.toml
RUN mkdir -p /root/.config/fish && \
    echo 'starship init fish | source' > /root/.config/fish/config.fish && \
    echo 'fish_vi_key_bindings' >> /root/.config/fish/config.fish

RUN mkdir -p /etc/fish/conf.d
COPY motd.fish /etc/fish/conf.d/99-motd.fish

WORKDIR /workspace

# Fish als Standard-Shell
CMD ["fish"]

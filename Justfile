# Variablen
registry := "ghcr.io/kkroesch/pivot-stack"
version := `git rev-parse --short HEAD || date +%Y%m%d`

# Standard-Target
default: build

# Baut das Image mit podman/buildah
build type="server":
    @echo "Baue Image Version: {{version}}"
    podman build -t {{registry}}:{{version}} -t {{registry}}:latest -f Containerfile.{{type}} .

# Schiebt das Image in deine selbst gehostete Registry
push: build
    podman push {{registry}}:{{version}}
    podman push {{registry}}:latest

# Startet das Image lokal zum Testen
run:
    podman run -it --rm -v {{invocation_directory()}}:/workspace:Z {{registry}}:latest

# Testet, ob alle Kern-Tools im Container verfügbar und ausführbar sind
test:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "Führe Command-Tests in {{registry}}:latest aus..."
    
    podman run --rm "{{registry}}:latest" bash -c '
        COMMANDS=("uv" "marimo" "duckdb" "dvc" "vd" "nvim" "fish" "starship" "just")
        FAILED=0
        
        for cmd in "${COMMANDS[@]}"; do
            if command -v "$cmd" >/dev/null 2>&1; then
                echo "✅ $cmd ist verfügbar"
            else
                echo "❌ $cmd FEHLT"
                FAILED=1
            fi
        done
        
        if [ $FAILED -ne 0 ]; then
            echo "Fehler: Nicht alle Tools wurden gefunden."
            exit 1
        fi
        
        echo "🎉 Alle Tools erfolgreich getestet!"
    '

# Startet den Container persistent zum neu verbinden
stay:
    podman run -dt --name pivot_stack -p 2718:2718 -v $(pwd):/workspace:Z ghcr.io/kkroesch/pivot-stack:latest

# Verbindet auf den laufenden Container
connect:
    podman exec -it pivot_stack fish

# Startet Marimo im laufenden Container
serve notebook="":
    podman exec -it pivot_stack marimo edit --host 0.0.0.0 --port 2718 {{ notebook }}

toolbox:
    -toolbox rm --force pivot_stack 2>/dev/null
    toolbox create --image {{registry}}:toolbox --container pivot_stack
    toolbox run --container pivot_stack fish


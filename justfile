set windows-shell := ["bash", "-c"]

widget_name := "timer"
dist_dir    := "dist"

default:
    @just --list

dev:
    docker compose up --detach
    @echo "Dev server: http://localhost:8888"

stop:
    docker compose down

build:
    mkdir -p {{dist_dir}}
    icuewidget build

package:
    mkdir -p {{dist_dir}}
    MSYS_NO_PATHCONV=1 docker run --rm \
        -v "$(pwd)/src:/widget" \
        -v "$(pwd)/{{dist_dir}}:/output" \
        -e WIDGET_NAME={{widget_name}} \
        icue-packager:latest

install: package
    explorer.exe "$(wslpath -w {{justfile_directory()}}/{{dist_dir}}/{{widget_name}}.icuewidget)"

clean:
    rm -rf {{dist_dir}}
    docker compose down --remove-orphans

#!/bin/bash
if command -v vim >/dev/null 2>&1; then
    vim +PlugClean! +PlugInstall +qall
fi

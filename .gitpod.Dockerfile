FROM gitpod/workspace-full

# Install graphviz
RUN sudo apt-get update --fix-missing \
    && sudo apt-get install -y graphviz

USER gitpod

FROM mambaorg/micromamba:jammy

WORKDIR /work

## create environment 
COPY env.yaml env.yaml
RUN micromamba install --yes --quiet --name=base --file=env.yaml

## run as python
ENV PYTHONPATH=/work
ENTRYPOINT ["micromamba","run","python"]

# ENTRYPOINT ["bash"]

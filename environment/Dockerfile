FROM mambaorg/micromamba:jammy

RUN micromamba install --yes --quiet --name=base -c conda-forge git

# ## create environment 
# COPY env.yaml env.yaml
# RUN micromamba install --yes --quiet --name=base --file=env.yaml


ENTRYPOINT ["micromamba","run","python"]

## -*- compile-command: "time cd ~/projects/vannier/agent_template/ ; ./environment/run_in_conda_environment.bash python -m agent_template example_config.yaml" ; -*-


from . import run
    
if __name__ == "__main__":
    run.main()



"""Post-project generation hooks"""

if __name__ == '__main__':
    """Initialize a git repository."""

    with open('.envrc', 'a') as envrc:
        envrc.write('use flake .\n')

    import subprocess
{%- if cookiecutter.testing_framework == 'none' %}
    subprocess.call(('bash', '-c', 'rm -fr *-tests.* tests'))
{%- endif %}

    subprocess.call(('git', 'init'))
    subprocess.call(('git', 'add', '.'))

    print("Project {{ cookiecutter.project_name }} created succesfully.")

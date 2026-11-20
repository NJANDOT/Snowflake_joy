import subprocess, shutil, traceback

out_path = r'c:\Users\jandot.nicolas\git\Snowflake_joy\dbt_parse_result.txt'
try:
    dbt = shutil.which('dbt')
    result = subprocess.run(
        [dbt, 'parse',
         '--project-dir', r'c:\Users\jandot.nicolas\git\Snowflake_joy\sf_sandbox',
         '--profiles-dir', r'C:\Users\jandot.nicolas\.dbt'],
        capture_output=True, text=True, timeout=120
    )
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(f'RC: {result.returncode}\n')
        f.write(result.stdout)
        if result.stderr:
            f.write('\nSTDERR:\n')
            f.write(result.stderr)
except Exception:
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(traceback.format_exc())

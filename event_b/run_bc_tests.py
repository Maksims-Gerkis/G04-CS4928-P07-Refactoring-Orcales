import json, re, os, sys, subprocess, shutil, csv
P, OUT, JAR = sys.argv[1], sys.argv[2], sys.argv[3]
env = dict(os.environ, JAVA_TOOL_OPTIONS='')
ids = [2,4,6,8,10,12,14,16,18,20,50,53,54]
build = os.path.join(OUT, '_build'); shutil.rmtree(build, ignore_errors=True)
rows = []
def javac(cp, d, files):
    os.makedirs(d, exist_ok=True)
    r = subprocess.run(['javac', '-cp', cp, '-d', d] + files, capture_output=True, text=True, env=env)
    return r.returncode == 0, r.stdout + r.stderr
def java_srcs(folder):
    return [os.path.join(dp, f) for dp, _, fs in os.walk(folder) for f in fs if f.endswith('.java') and 'Test' not in f]
for i in ids:
    raw = open(f'{P}/raw_outputs/{i}.json', encoding='utf-8-sig').read()
    t = raw.replace('“', '"').replace('”', '"')
    verdict = (re.search(r'"verdict"\s*:\s*"([^"]+)"', t) or [None, ''])[1].strip()
    test = None
    try:
        test = json.loads(t).get('junit_test')
    except Exception:
        m = re.search(r'"junit_test"\s*:\s*"(.*)"\s*}\s*$', t, re.S)
        if m:
            try: test = json.loads('"' + m.group(1) + '"')
            except Exception: test = m.group(1).encode().decode('unicode_escape')
    row = dict(case=i, verdict=verdict, test_compiles_orig='', test_compiles_res='', orig_result='', res_result='', outcome='')
    logdir = os.path.join(OUT, 'logs'); os.makedirs(logdir, exist_ok=True)
    if not test:
        row['outcome'] = 'no test'; rows.append(row); continue
    cls = re.search(r'public\s+class\s+(\w+)', test).group(1)
    pkg = re.search(r'^\s*package\s+([\w.]+)\s*;', test, re.M)
    fq = (pkg.group(1) + '.' if pkg else '') + cls
    tdir = os.path.join(OUT, 'tests', str(i), *(pkg.group(1).split('.') if pkg else []))
    os.makedirs(tdir, exist_ok=True); tf = os.path.join(tdir, cls + '.java')
    open(tf, 'w', newline='\n').write(test.rstrip() + '\n')
    jupiter = 'org.junit.jupiter' in test
    res = {}
    for v in ('original', 'resulting'):
        ok, log = javac(JAR, f'{build}/{i}/{v}', java_srcs(f'{P}/cases/{i}/{v}'))
        assert ok, (i, v, log)
        tok, tlog = javac(f'{build}/{i}/{v}:{JAR}', f'{build}/{i}/t_{v}', [tf])
        row['test_compiles_' + ('orig' if v == 'original' else 'res')] = tok
        txt = tlog
        if tok:
            cp = f'{build}/{i}/t_{v}:{build}/{i}/{v}:{JAR}'
            cmd = (['java', '-jar', JAR, '-cp', cp, '--select-class', fq, '--disable-banner'] if jupiter
                   else ['java', '-cp', cp, 'org.junit.runner.JUnitCore', fq])
            r = subprocess.run(cmd, capture_output=True, text=True, env=env, timeout=60)
            txt += r.stdout + r.stderr; res[v] = 'PASS' if r.returncode == 0 else 'FAIL'
        else: res[v] = 'TEST DOES NOT COMPILE'
        open(os.path.join(logdir, f'{i}_{v}.txt'), 'w').write(txt)
    row['orig_result'], row['res_result'] = res['original'], res['resulting']
    if 'TEST DOES NOT COMPILE' in res.values(): row['outcome'] = 'test does not compile'
    elif res['original'] == 'PASS' and res['resulting'] == 'FAIL': row['outcome'] = 'confirmed'
    elif res['original'] == res['resulting']: row['outcome'] = 'does not expose change'
    else: row['outcome'] = 'inverted (fails on original, passes on resulting)'
    rows.append(row)
shutil.rmtree(build, ignore_errors=True)
with open(os.path.join(OUT, 'bc_test_results.csv'), 'w', newline='') as f:
    w = csv.DictWriter(f, fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)
for r in rows: print(r)

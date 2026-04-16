"""
Dash-Replacer fuer Miraculix-Vault.
Phase 1: Dry-Run - zaehlen wo Em-Dashes (U+2014) und En-Dashes (U+2013) stehen.
Phase 2: Replace - beide durch ASCII-Bindestrich (-) ersetzen.
"""
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

VAULT = r"C:\Users\deniz\Documents\miraculix"
EXCLUDE_DIRS = {'.git', '.obsidian', '_api', '.tmp.drivedownload', '.tmp.driveupload', 'node_modules'}
EM_DASH = '\u2014'
EN_DASH = '\u2013'

def walk_md_files(root):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for fn in filenames:
            if fn.endswith('.md'):
                yield os.path.join(dirpath, fn)

def phase1_count():
    total_em = 0
    total_en = 0
    files_affected = []
    for path in walk_md_files(VAULT):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            em = content.count(EM_DASH)
            en = content.count(EN_DASH)
            if em + en > 0:
                files_affected.append((path, em, en))
                total_em += em
                total_en += en
        except Exception as e:
            print(f"ERR {path}: {e}")
    return total_em, total_en, files_affected

def phase2_replace():
    changed = 0
    for path in walk_md_files(VAULT):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            new = content.replace(EM_DASH, '-').replace(EN_DASH, '-')
            if new != content:
                with open(path, 'w', encoding='utf-8', newline='') as f:
                    f.write(new)
                changed += 1
        except Exception as e:
            print(f"ERR {path}: {e}")
    return changed

if __name__ == '__main__':
    mode = sys.argv[1] if len(sys.argv) > 1 else 'count'
    if mode == 'count':
        em, en, affected = phase1_count()
        print(f"FILES_AFFECTED: {len(affected)}")
        print(f"EM_DASHES: {em}")
        print(f"EN_DASHES: {en}")
        print(f"TOTAL: {em + en}")
        print("---")
        for path, e_em, e_en in sorted(affected, key=lambda x: -(x[1]+x[2]))[:15]:
            rel = os.path.relpath(path, VAULT)
            print(f"  {e_em + e_en:4d}  {rel}")
    elif mode == 'replace':
        n = phase2_replace()
        print(f"CHANGED_FILES: {n}")

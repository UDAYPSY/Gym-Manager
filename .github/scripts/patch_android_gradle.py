import glob
import os
import re

def patch_gradle_files():
    local_props = 'android/local.properties'
    try:
        os.makedirs(os.path.dirname(local_props), exist_ok=True)
        with open(local_props, 'a', encoding='utf-8') as f:
            f.write('\nflutter.minSdkVersion=23\n')
        print(f"Added flutter.minSdkVersion=23 to {local_props}")
    except Exception as e:
        print(f"Notice: could not update {local_props}: {e}")

    gradle_files = glob.glob('android/app/build.gradle*')
    print(f"Found gradle files to patch: {gradle_files}")
    for file_path in gradle_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        is_kts = file_path.endswith('.kts')
        
        if is_kts:
            content = re.sub(r'^\s*.*minSdk.*$', '        minSdk = 23', content, flags=re.MULTILINE)
            content = re.sub(r'namespace\s*=\s*["\'][^"\']+["\']', 'namespace = "com.gymmanager.app"', content)
            content = re.sub(r'applicationId\s*=\s*["\'][^"\']+["\']', 'applicationId = "com.gymmanager.app"', content)

            store_pwd = os.environ.get('STORE_PASSWORD') or 'gymmanager2026'
            key_alias = os.environ.get('KEY_ALIAS') or 'gymmanager'
            key_pwd = os.environ.get('KEY_PASSWORD') or 'gymmanager2026'

            kts_signing = f'''    signingConfigs {{
        create("release") {{
            storeFile = file("${{project.projectDir}}/release.jks")
            storePassword = "{store_pwd}"
            keyAlias = "{key_alias}"
            keyPassword = "{key_pwd}"
        }}
    }}'''
            if 'signingConfigs {' in content:
                content = re.sub(r'signingConfigs\s*\{.*?\n    \}', kts_signing, content, flags=re.DOTALL)
            content = re.sub(r'signingConfig\s*=\s*signingConfigs\.getByName\(["\']debug["\']\)', 'signingConfig = signingConfigs.getByName("release")', content)
        else:
            if re.search(r'minSdk\s*=', content):
                content = re.sub(r'^\s*.*minSdk.*$', '        minSdk = 23', content, flags=re.MULTILINE)
            else:
                content = re.sub(r'^\s*.*minSdk(Version)?.*$', '        minSdkVersion 23', content, flags=re.MULTILINE)
            content = re.sub(r'namespace\s+["\'][^"\']+["\']', 'namespace "com.gymmanager.app"', content)
            content = re.sub(r'namespace\s*=\s*["\'][^"\']+["\']', 'namespace = "com.gymmanager.app"', content)
            content = re.sub(r'applicationId\s+["\'][^"\']+["\']', 'applicationId "com.gymmanager.app"', content)
            content = re.sub(r'applicationId\s*=\s*["\'][^"\']+["\']', 'applicationId = "com.gymmanager.app"', content)

            store_pwd = os.environ.get('STORE_PASSWORD') or 'gymmanager2026'
            key_alias = os.environ.get('KEY_ALIAS') or 'gymmanager'
            key_pwd = os.environ.get('KEY_PASSWORD') or 'gymmanager2026'

            groovy_signing = f'''    signingConfigs {{
        release {{
            storeFile file("${{project.projectDir}}/release.jks")
            storePassword '{store_pwd}'
            keyAlias '{key_alias}'
            keyPassword '{key_pwd}'
        }}
    }}'''
            if 'signingConfigs {' in content:
                content = re.sub(r'signingConfigs\s*\{.*?\n    \}', groovy_signing, content, flags=re.DOTALL)
            else:
                content = content.replace('android {', f'android {{\n{groovy_signing}')
            
            content = re.sub(
                r'signingConfig\s*=?\s*signingConfigs\.\w+',
                'signingConfig signingConfigs.release',
                content
            )

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Patched: {file_path}")

if __name__ == '__main__':
    patch_gradle_files()

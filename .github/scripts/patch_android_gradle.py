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

def patch_manifest():
    manifest_paths = ['android/app/src/main/AndroidManifest.xml']
    for path in manifest_paths:
        if os.path.exists(path):
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            content = re.sub(r'package\s*=\s*["\'][^"\']+["\']', 'package="com.gymmanager.app"', content)
            if 'android:name="com.gymmanager.app.MainActivity"' not in content and 'android:name=".MainActivity"' not in content:
                content = content.replace('android:name="', 'android:name="com.gymmanager.app.MainActivity" <!-- ')
            if 'android.permission.INTERNET' not in content:
                content = content.replace('<application', '<uses-permission android:name="android.permission.INTERNET"/>\n    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>\n\n    <application')
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Patched AndroidManifest at {path}")

def patch_main_activity():
    activity_files = glob.glob('android/app/src/main/**/MainActivity.*', recursive=True)
    full_activity_code = '''package com.gymmanager.app

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
'''
    for file_path in activity_files:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(full_activity_code)
        print(f"Enforced correct MainActivity at {file_path}")

def patch_repositories():
    targets = glob.glob('android/**/*.gradle*', recursive=True)
    for path in targets:
        try:
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            if 'mavenCentral()' in content and 'https://repo1.maven.org/maven2/' not in content:
                if path.endswith('.kts'):
                    content = content.replace(
                        'mavenCentral()',
                        'mavenCentral()\n        maven("https://repo1.maven.org/maven2/")'
                    )
                else:
                    content = content.replace(
                        'mavenCentral()',
                        "mavenCentral()\n        maven { url 'https://repo1.maven.org/maven2/' }"
                    )
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Added repo1.maven.org fallback to {path}")
        except Exception as e:
            print(f"Notice: could not patch repos in {path}: {e}")

if __name__ == '__main__':
    patch_gradle_files()
    patch_repositories()
    patch_manifest()
    patch_main_activity()

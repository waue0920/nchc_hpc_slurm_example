import sys
import os

def print_python_env():
    print("=== Python Environment Variables ===")
    print("\n1. Python Version:")
    print(sys.version)
    print("\n2. Python Executable Path:")
    print(sys.executable)
    print("\n3. Python Library Paths (sys.path):")
    for path in sys.path:
        print(f" - {path}")
    print("\n4. PYTHONPATH Environment Variable:")
    print(os.environ.get('PYTHONPATH', 'Not Set'))
    print("\n5. LD_LIBRARY_PATH Environment Variable:")
    print(os.environ.get('LD_LIBRARY_PATH', 'Not Set'))
    print("\n6. PATH Environment Variable:")
    print(os.environ.get('PATH', 'Not Set'))
    print("\n7. USER_SITE (User-installed Libraries):")
    print(sys.prefix + '/lib/python' + sys.version[:3] + '/site-packages')
    print("\n8. USER_BASE (Pip --user Libraries):")
    print(os.path.expanduser('~/.local'))

if __name__ == "__main__":
    print_python_env()

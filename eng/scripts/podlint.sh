
#!/bin/sh

#  podlint.sh
PWD=$(pwd)

python3 "$PWD/eng/scripts/util.py" list_podspecs |
while IFS= read -r line;do
    pod lib lint $line --quick
    pod spec lint $line --quick
done

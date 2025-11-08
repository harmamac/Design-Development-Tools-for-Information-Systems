
dirpath="."
mask="*"
number=$(nproc)
command=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --path)
            dirpath="$2"
            shift 2
            ;;
        --mask)
            mask="$2"
            shift 2
            ;;
        --number)
            number="$2"
            shift 2
            ;;
        *)
            command="$1"
            shift
            ;;
    esac
done

if [ -z "$command" ]; then
    echo "Error: command is required"
    exit 1
fi

if [ ! -d "$dirpath" ]; then
    echo "Error: Directory $dirpath does not exist"
    exit 1
fi

if [ ! -x "$command" ] && ! command -v "$command" &> /dev/null; then
    echo "Error: Command $command is not executable or not found"
    exit 1
fi

if [ -z "$mask" ]; then
    echo "Error: Mask cannot be empty"
    exit 1
fi

if ! [[ "$number" =~ ^[0-9]+$ ]] || [ "$number" -le 0 ]; then
    echo "Error: Number must be a positive integer"
    exit 1
fi

dirpath=$(cd "$dirpath" && pwd)

files=()
shopt -s nullglob
cd "$dirpath"
for file in $mask; do
    if [ -f "$file" ]; then
        files+=("$dirpath/$file")
    fi
done
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
    exit 0
fi

running=0
file_index=0
total_files=${#files[@]}

while [ $file_index -lt $total_files ]; do
    while [ $running -ge $number ]; do
        wait -n
        ((running--))
    done
    
    "$command" "${files[$file_index]}" &
    ((running++))
    ((file_index++))
done
wait
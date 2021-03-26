# EOPSY LAB1 Vladyslav Makartet 302263
#!/usr/bin/bash
help_usage () {
	cat <<HELP_USAGE
Name:
          $(basename $0) is a script which is used for modification of filenames such that it is able to lowercase/uppercase
          or change a filename according to provided sed pattern.

Usage:
          modify [-r] [-l|-u] <dir/file names...>
          modify [-r] <sed pattern> <dir/file names...>
          modify [-h]
Options:
          -r            turn on recursion, goes recursively through directories
          -l|-u         lowercase or uppercase, cannot be both at the same time
          -h            help message
          <sed pattern> pattern(regular expression) with which file name will be modified
Explanation:
          - the script cannot run with [-l|-u] flags at the same time.
          - when no -l|-u flag specified, it is considered to be a <sed pattern>
          - if in file path no filename specified, the script will change all files inside the provided directory (-r flag must be added)
          - if recursion is turned on and provided filename, the script will find all the occurrances of the given filename and change it
Example:
          modify -u ./example_dir/example.txt
                                            => file example.txt will be changed to EXAMPLE.txt
          modify -r -u ./example_dir/example_subfolder/
                                            => all the files inside example_subfolder will be capitalized
          modify -l ./example_dir/EXAMPLE1.txt ./example_dir/example_dir_two/EXAMPLE2.txt
                                            => file EXAMPLE1.txt and EXAMPLE2.txt will be changed to example1.txt and example2.txt
          modify -r 's/  */@@@@/g' 'file with many spaces.txt'
                                            => all occurrances of "file with many spaces.txt" will be changed to "file@@@@with@@@@many@@@@spaces.txt"
HELP_USAGE
exit 0
}

# If no arguments supplied, print usage help and exit
if [ -z "$1" ]; then
	help_usage
fi
# print occurred error
error_msg() {
	echo "$0: Error: $1" 1>&2 # redirect stdout to stderr
	exit 1
}

# Values of arguments
recursion=0
upperCase=0
lowerCase=0
helpMsg=0
sedPattern=""
# Set values according to the provided arguments
while getopts "rluh" arguments; do
    case ${arguments} in
        r) recursion=1;; # Set recursion to 1
        l) lowerCase=1;; # Set lowercase to 1
        u) upperCase=1;; # Set upperCase to 1
        h) helpMsg=1;;   # Set helpMsg to 1
        *) error_msg "Type -h for help.";; # Wrong option was provided
    esac
done

# Shift to the first non-option argument passed
shift "$((OPTIND-1))"
# Show error if -l or -u and -h provided
if [ $lowerCase -eq 1 ] || [ $upperCase -eq 1 ] && [ $helpMsg -eq 1 ]; then
    error_msg "Cannot run with [-h] and [-u|l] flag arguments. Please run the script with [-h|u|l]. Type [-h] for more info."
fi
# Show error if -l and -u were provided
if [ $lowerCase -eq 1 ] && [ $upperCase -eq 1 ]; then
    error_msg "Cannot run with [-u] and [-l] flag arguments at the same time. Please run the script with [-u|l]. Type [-h] for more info."
fi
# If the first argument is [-h], print usage help and exit
if [ $helpMsg -eq 1 ]; then
    help_usage
fi
# If -l or -u were not specified, set pattern for sed
if [ "$lowerCase" -eq 0 ] && [ "$upperCase" -eq 0 ]; then
    sedPattern=$1
    shift # go to the next argument
fi
# convert remaining file arguments into an actual array for further processing
myArray=( "$@" )
# If array is empty, show error and exit
if [ ${#myArray[@]} -eq 0 ]; then
    error_msg "Please check the correctness of your input and try again."
fi
# File iterations
for ptr in "${myArray[@]}"; do
    # check if arguments are passed incorrectly
    if [ "$ptr" = "-l" ] || [ "$ptr" = "-u" ] && [ ! -z "$sedPattern" ];then
        error_msg "Cannot modify file with \"$sedPattern\" sed pattern and \"$ptr\" flag at the same time. Type -h to see more info on passing arguments."
    fi
    # if recursion is on, find all occurrances of the file specified (goes into all sub_dirdir)
    if [ $recursion -eq 1 ]; then
        find_parameter="find -type f | grep '${ptr}'"
    else
    # finds provided file without going to sub_dirs (no recursion)
        find_parameter="find '${ptr}' -maxdepth 0"
    fi
    # find_parameter read and concatenated together into a single command, the result is in filepath
    eval $find_parameter | while read -r filepath; do
        directory_name=$(dirname "$filepath") # get directory_name
        file_name=$(basename "$filepath") # get file_name
        if [ -d "${filepath}" ]; then # # check for folders to avoid renaiming them
            error_msg "Cannot rename folders. If you wanted to rename all the files inside the folder, use -r flag."
        # if no -l or -u were provided, execute sed command with the sedPattern
        elif [ ! -z "$sedPattern" ]; then
            newname=$(echo -n "${file_name}" | sed -s "$sedPattern")
        else
        # otherwise change filename according to the given -l or -u argument
            name=${file_name%.*} # delete everything after last dot
            ext=${file_name##*.} # delete everything up to last dot

            if [ "$name" = "$ext" ]; then
                if [ $lowerCase -eq 1 ]; then
                    newname=${name,,*} # lowerCase file without extension
                fi
                if [ $upperCase -eq 1 ]; then
                    newname=${name^^*} # upperCase file without extension
                fi
            else
                if [ $lowerCase -eq 1 ]; then
                    newname=${name,,*}.$ext # lowerCase file with extension
                fi
                if [ $upperCase -eq 1 ]; then
                    newname=${name^^*}.$ext # upperCase file with extension
                fi
            fi
        fi
        # If obtained file with new name already exists do not change it
        if [ "$file_name" != "$newname" ] && [ ! -e "${directory_name}/${newname}" ]; then
            # rename with new name
            mv "$filepath" "${directory_name}/${newname}"
        else
            echo "Warning: File \"$directory_name/$file_name\" was not changed to \"$newname\" to avoid overwrite."
            continue
        fi
    done
done

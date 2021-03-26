# EOPSY LAB1 Vladyslav Makartet 302263
#!/usr/bin/bash
# supply name of the tested script, by default considered to be modify.sh
if [ -z $1 ]; then
    script_call="modify.sh"
else   
    script_call="$1" # otherwise take from the argument list
fi
# print occurred error
error_msg_modify_example(){
	echo "$0: Error: $1" 1>&2 # redirect stdout to stderr
	exit 1
}
# ask if the test command was executed correctly
test_message(){
    echo
    read -p "Was the command executed correctly?(yes-y/no-n): " condition
    if [ "$condition" = "y" ]; then
        echo "Test passed!";
    elif [ "$condition" = "n" ]; then
        echo "Failed! Stopping the script!"
        exit 1
    else 
        error_msg_modify_example "Incorrect input!"
    fi
}
# create folders for modify_examples.sh
# if modify_example folder was created before, delete it and create with proposed structure
if [ -e "modify_example" ]; then
    echo
    echo "Please make sure that you have nothing important in \"modify_example\""
    echo "The folder will be overwritten!"
    read -n 1 -s -r -p "Press any key to continue..."
    echo;echo
    rm -r modify_example
    if [ ! -e "modify_example" ]; then
        echo "Old modify_example folder was deleted!"
    else
        error_msg_modify_example "Cannot delete the folder!"
    fi
    
fi
mkdir -p "modify_example/subfolder1"
mkdir -p "modify_example/SUBFOLDER2"
mkdir -p "modify_example/-subfolder3"
mkdir -p "modify_example/!#-&()sub!#-&()folder4!#-&()"
mkdir -p "modify_example/'sub\ folder5'"
mkdir -p "modify_example/-*subFolder__6"
mkdir -p "modify_example/'sub\ folder\ 7'"
mkdir -p "modify_example/!@#$%^&*()subfolder8"
mkdir -p "modify_example/Subfolder9"
mkdir -p "modify_example/subfolder10/subfolder10_1/subfolder10_2/subfolder10_3/subfolder10_4/subfolder10_5/subfolder10_6/subfolder10_7/very_deep_folder"
mkdir -p "modify_example/subfolder11/subfolder11/'sub\ folder11/*(@subfolder11"
mkdir -p "modify_example/Sub folder 12"
if [ -e "modify_example" ]; then
    echo;echo "New \"modify_example\" folder was successfully created!"
else
    error_msg_modify_example "Something went wrong, please try again!"
fi
# create files with some text inside 
for d in ./modify_example/*/ ; do
    echo "Examplary file content1" > "$d"/simplefile.txt
    echo "Examplary file content2" > "$d"/SIMPLE_FILE.txt
    echo "Examplary file content3" > "$d"/'simple file.txt'
    echo "Examplary file content4" > "$d"/'-*1simpleFILE.txt'
    echo "Examplary file content5" > "$d"/'\!@#??$%^&*()1simple!@#$%^&*()FILE.txt'
    echo "Examplary file content6" > "$d"/"-----simple!@\#\$--%^&*()FILE.txt"
    echo "Examplary file content7" > "$d"/'file with many spaces.txt'
    echo "Examplary file content8" > "$d"/file.with.some.dots.txt
    echo "Examplary file content8" > "$d"/'file with no extensions'
done
echo "Examplary file content of very deep folder!" > "modify_example/subfolder10/subfolder10_1/subfolder10_2/subfolder10_3/subfolder10_4/subfolder10_5/subfolder10_6/subfolder10_7/very_deep_folder/simple_FILE.txt"
echo "Examplary file content of very deep folder!" > "modify_example/subfolder10/subfolder10_1/subfolder10_2/subfolder10_3/subfolder10_4/subfolder10_5/subfolder10_6/subfolder10_7/very_deep_folder/one_more_simple_file.txt"

echo;echo
echo "<========================Test cases========================>"
echo
#Test cases
echo "Test case #1 with displaying help menu!"
sh ./$script_call -h
test_message
echo;echo
echo "Test case #2 with uppercase, file ./subfolder1/simplefile.txt"
echo "The file must be changed to SIMPLEFILE.txt"
sh ./$script_call -u ./modify_example/subfolder1/simplefile.txt
test_message
echo;echo
echo "Test case #3 with lowercase, file ./subfolder1/SIMPLE_FILE.txt"
echo "The file must be changed to simple_file.txt"
sh ./$script_call -l ./modify_example/subfolder1/SIMPLE_FILE.txt
test_message
echo;echo
echo "Test case #4 with recursion and uppercase, all the files in ./SUBFOLDER2/"
echo "All the files must be changed to uppercase and give one warning about overwrite"
sh ./$script_call -r -u ./modify_example/SUBFOLDER2/
test_message
echo;echo
echo "Test case #5 with recursion and lowercase, all the files in ./SUBFOLDER2/"
echo "All the files must be changed to lowercase"
sh ./$script_call -r -l ./modify_example/SUBFOLDER2/
test_message
echo;echo
echo "Test case #6 with recursion and one filename, all occurrances of file \"file with no extensions\"" 
echo "All the occurrances must be changed to uppercase"
sh ./$script_call -r -u 'file with no extensions'
test_message
echo;echo
echo "Test case #7 with recursion and one filename, all occurrances of file \"FILE WITH NO EXTENSIONS\"" 
echo "All the occurrances must be changed to lowercase"
sh ./$script_call -r -l 'FILE WITH NO EXTENSIONS'
test_message
echo;echo
echo "Test case #8 with sed pattern, file ./SUBFOLDER2/'file with no extensions'" 
echo "Substitute all white spaces with ###"
sh ./$script_call 's/  */###/g' ./modify_example/SUBFOLDER2/'file with no extensions'
test_message
echo;echo
echo "Test case #9 with recursion and sed pattern, all occurances of file \"file with many spaces.txt\"" 
echo "Substitute all white spaces with @@@@"
sh ./$script_call -r 's/  */@@@@/g' 'file with many spaces.txt'
test_message
echo;echo
echo "Test case #10 with recursion, rename all files to uppercase" 
echo "Rename all the files in all folders to uppercase, should give warnings about SIMPLE_FILE.txt"
sh ./$script_call -r -u ./modify_example/
test_message
echo;echo
echo "Test case #11 with recursion, rename all files to lowercase" 
echo "Rename all the files in all folders to lowercase"
sh ./$script_call -r -l ./modify_example/
test_message
echo;echo
echo "<========================Test cases which result in error========================>"
echo;echo
echo "Test case #12 with -h -l -u flags at the same time"
echo "The script must output error"
sh ./$script_call -h -l -u
test_message
echo;echo
echo "Test case #13 with -h -l flags"
echo "The script must output error"
sh ./$script_call -h -l
test_message
echo;echo
echo "Test case #14 with -l -u flags"
echo "The script must output error"
sh ./$script_call -l -u
test_message
echo;echo
echo "Test case #15 with -l -u flags and file"
echo "The script must output error"
sh ./$script_call -l -u ./modify_example/subfolder1/simplefile.txt
test_message
echo;echo
echo "Test case #16 with -l -u flags and sed pattern" 
echo "The script must output error"
sh ./$script_call -l -u 's/  */@@@@/g' 
test_message
echo;echo
echo "Test case #17 with -u flag and folder without -r flag" 
echo "The script must output error"
sh ./$script_call -u ./modify_example/subfolder1/
test_message
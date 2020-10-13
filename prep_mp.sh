#!/bin/bash
# ^^^^^^^^^ THIS MUST BE THE FIRST LINE IN YOUR SCRIPT (for linux scripts)
# the "#!" shebang sets context, determining path to interpreter that runs the shell
################################################################################
# CREATED BY: Devin Headrick on # 09/28/2020

# Change this path if you want to keep your script in a different dir
script_path="/usr/local/bin"

# Assign tar file path, requested path for extracted file, and mp number, to variables
if [ "$#" = "3" ]; then
  tar_location=$1
  extract_to_location=$2
  problem_num=$3

  #check if a tar file is present in the specified directory before attempting script
  if test -f "${tar_location}/"*.tar.gz; then
    echo "getting tar from: ${tar_location}"
    echo "extracted file will be sent to: ${extract_to_location}"

    if [ -f ${script_path}/custom_mp_header.txt ]; then
      #grab current date and time from system
      current_date=`date +"%m-%d-%Y / %H:%M:%S %p"`
      echo $current_date
      #remove third line holding previous date
      sudo sed -i '3d' ${script_path}/custom_mp_header.txt
      #insert new date into line 3
      sudo sed -i "3 i # Date  : ${current_date}" ${script_path}/custom_mp_header.txt

      #look for a tar file in the specified directory - grab the name
      file_name=$(find $tar_location -maxdepth 1 -type f -name "*.tar.gz")
      problem_name="${file_name%*.*.*}"
      problem_name="${problem_name#./}"

      echo ${problem_name}

      #TODO test this
      #extract (untar) the morning problem to specified dir
      tar -xf "$file_name" -C ${extract_to_location}

      #change file name to include the problem num and name
      new_folder_name="mp${problem_num}_${problem_name}"
      mv "${extract_to_location}/${problem_name}" "${extract_to_location}/${new_folder_name}"

      #place the tar file in the new folder to clear clutter
      mv "${tar_location}/${file_name}" "${extract_to_location}/${new_folder_name}"

      #check if a pre-existing .py template is in the soln folder
      if [ -f "${extract_to_location}/${new_folder_name}"/soln/*.py ]; then
        echo "Pre-existing python template found"


        # prepend custom header onto file
        cat ${script_path}/custom_mp_header.txt "${extract_to_location}/${new_folder_name}"/soln/*.py > temp && mv temp "${extract_to_location}/${new_folder_name}"/soln/*.py
        #change ownership back to original user (performing header cat changes owner to root ~ ? IDK WHY )
        chown cmput274 "${extract_to_location}/${new_folder_name}"/soln/*.py


        #open the morning problem template .py file in atom
        atom "${extract_to_location}/${new_folder_name}"/soln/*.py
      else
        echo "NO pre-existing python template found! - Creating python file"
        #create a new .py file labelled as the problem name and cat custom header
        touch "${extract_to_location}/${new_folder_name}/soln/${problem_name}.py"
        #prepend custom header onto file
        cat header_template.txt "${extract_to_location}/${new_folder_name}/soln/${problem_name}.py" > temp && mv temp "${extract_to_location}/${new_folder_name}"/soln/*.py
        #change ownership back to original user (performing header cat changes owner to root ~ ? IDK WHY )
        chown cmput274 "${extract_to_location}/${new_folder_name}"/soln/*.py
        #open the morning problem template .py file in atom
        atom "${extract_to_location}/${new_folder_name}/soln/${problem_name}.py"
      fi
    else
      echo "No custom_mp_header.txt file found. Place the custom_mp_header.txt file in same location as script file"
    fi
  else
    echo "No tar file found in specified directory: ${tar_location}"
    echo "Please place a morning problem tar file into your specified dir before running script"
  fi

else
  echo "Improper arguments ($#) defined!  See required below"
  echo "Arg1: path to the tar file"
  echo "Arg2: Path you would like it extracted to"
  echo "Arg3: Morning problem number (chronological)"
  echo "Example: prep_mp.sh tar/is/located/here/ /extract/to/here 5"
fi

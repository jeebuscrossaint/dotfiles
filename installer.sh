echo "Welcome to the shlawg config! Would you like to (Re)install all your configurations? This installer is meant for Arch/Arch based distributions."
confirm=""
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
echo "Do you have an NVIDIA GPU? Read the text below to check if you do or do not. IF it says NVIDIA anywhere then answer yes, if not answer no. This is due to nvidia's drivers being closed source like a bum."
lspci  -v -s  $(lspci | grep ' VGA ' | cut -d" " -f 1)
gpuconfirm=""
read -p "Explicitly answer Y or N to the above inquiry.
" gpuconfirm
if [ $gpuconfirm = Y ] 
then
	echo "installing nvidia pkgs"
if 
   [ $gpuconfirm = N ]
then
	echo "installing normal pkgs"
else
	echo "u dumb"
fi

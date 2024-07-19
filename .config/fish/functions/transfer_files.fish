function transfer_files
    set file $argv[1]
    if not test -f $file
        echo "Error: File '$file' not found"
        return 1
    end

    rsync -r --info=progress2 --info=name0 $file /mnt/usb/
end

function transfer_files
    if test (count $argv) -eq 0
        echo "Usage: transfer_files <file1.mkv> [file2.mkv] ..."
        return 1
    end

    set destination /mnt/usb/

    for file in $argv
        if not test -f $file
            echo "Warning: File '$file' not found, skipping."
            continue
        end

        echo "Transferring $file to $destination"
        rsync -r --info=progress2 --info=name0 $file $destination

        if test $status -ne 0
            echo "Error: Failed to transfer $file"
        else
            echo "Successfully transferred $file"
        end
    end

    echo "All transfers completed."
end

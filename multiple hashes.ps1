$algorithms = @("MD5", "SHA1", "SHA256", "BLAKE2", "SHA384", "SHA512")
$hashes = foreach ($algo in $algorithms) {
    $result = Get-FileHash HashTestFile1.txt -Algorithm $algo
    # Remove the trailing colon if it's not needed:
    "$($result.Algorithm): $($result.Hash)"
}
$hashes -join "`n"



curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

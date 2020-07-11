function import_csv([string]$file) {
    $list = Import-Csv $file -Delimiter ','
    return $list
}


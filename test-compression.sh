#!/bin/bash

set -eu
#set -x # Enable for debugging

to_compress="/path/to/file_or_folder_to_compress"
res_file="results.csv"

# Set to anything else to enable testing very slow algorithms such as xz and lzma (20 minutes for 4 GB)
skip_very_slow_algos="true"


if [[ ! -e $to_compress ]]; then
    echo "Specified file or folder '$to_compress' doesn't exist!"
    exit 1
fi

s_start=$(du -sb "$to_compress" | awk '{print $1}')

if [[ -f $res_file ]]; then
    echo "$res_file exists: will overwrite!"
    read -r -t 10 -p "You have 10 seconds to CTRL-C, or ENTER to confirm "
    echo ""
fi

outdir="${PWD}/tmp"
if [[ ! -d $outdir ]]; then
    mkdir -p "$outdir"
fi
baseout="$outdir/tmparch"

# Cleanup on exit
trap 'rm -r $outdir' EXIT

echo "Algorithm,Time(U+S)(s),Time(E)(M:s),ComprRatio,SpaceSave(%),T-Start(UT),T-End(UT),S-Start(b),S-End(b),Command" | tee $res_file

function timeit() {
    local the_command=("$@")

    echo "Timing: ${the_command[*]}"

    t_start=$(date +%s)
    export t_start
    output="$(command time -f '%U %S %E' "${the_command[@]}" 2>&1)"
    t_end=$(date +%s)
    export t_end
    user_time=$(echo "$output" | awk '{print $1}')
    export user_time
    sys_time=$(echo "$output" | awk '{print $2}')
    export sys_time
    total_time=$(bc <<< "$user_time + $sys_time")
    export total_time
    elapsed=$(echo "$output" | awk '{print $3}')
    export elapsed
    s_end=$(du -sb "$outfile" | awk '{print $1}')
    export s_end
    compr_r=$(bc <<< "scale=2; $s_start / $s_end")
    export compr_r
    saving=$(bc <<< "scale=2; 100 - ($s_end*100/$s_start)")
    export saving
}

function benchmark() {
    local algo=$1
    local outfile=$2
    local cmd=("${@:3}")

    timeit "${cmd[@]}"
    echo "$algo,$total_time,$elapsed,$compr_r,$saving,$t_start,$t_end,$s_start,$s_end,${cmd[*]}" | tee -a $res_file
    rm "$outfile"
}


if [[ $(which xz) && $skip_very_slow_algos != "true" ]]; then
    algo="xz"
    outfile="$baseout.tar.xz"
    command=("tar" "--absolute-names" "--xz" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "xz not found or manually skipped, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which gzip) ]]; then
    algo="gzip"
    outfile="$baseout.tar.gz"
    command=("tar" "--absolute-names" "--gzip" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "gzip not found, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which bzip2) ]]; then
    algo="bzip2"
    outfile="$baseout.tar.bz2"
    command=("tar" "--absolute-names" "--bzip2" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "bzip2 not found, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which lzip) ]]; then
    algo="lzip"
    outfile="$baseout.tar.lz"
    command=("tar" "--absolute-names" "--lzip" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "lzip not found, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which lzma) && $skip_very_slow_algos != "true" ]]; then
    algo="lzma"
    outfile="$baseout.tar.lzma"
    command=("tar" "--absolute-names" "--lzma" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "lzma not found or manually skipped, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which lzop) ]]; then
    algo="lzop"
    outfile="$baseout.tar.lzop"
    command=("tar" "--absolute-names" "--lzop" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "lzop not found, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which zstd) ]]; then
    algo="zstd"
    outfile="$baseout.tar.zst"
    command=("tar" "--absolute-names" "--zstd" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "zstd not found, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which lzip) ]]; then
    algo="lzip"
    outfile="$baseout.tar.lz"
    command=("tar" "--absolute-names" "--lzip" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "lzip not found, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which pigz) ]]; then
    algo="gzip (pigz)"
    outfile="$baseout.tar.gz"
    command=("tar" "--absolute-names" "-I" "pigz" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "pigz not found, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which lbzip2) ]]; then
    algo="bzip2 (lbzip2)"
    outfile="$baseout.tar.bz2"
    command=("tar" "--absolute-names" "-I" "lbzip2" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "lbzip2 not found, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which 7z) ]]; then
    algo="7z"
    outfile="$baseout.7z"
    command=("7z" "a" "-bso0" "-bsp0" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "7z not found, skipping"
fi
# --------------------------------------------------------------------------------------
# It has a somewhat strange use; I can't seem to find flags to suppress the output,
# and perhaps, by default, it deletes the file to be archived unless the -k option
# is passed (if so, who thought it would be a good idea?)

#if [[ $(which p7zip) ]]; then
#    algo="p7zip"
#    outfile="$baseout.7z"
#    command=("p7zip" "a" "-bso0" "-bsp0" "$outfile" "$to_compress")
#    benchmark "$algo" "$outfile" "${command[@]}"
#else
#    echo "p7zip not found, skipping"
#fi
# --------------------------------------------------------------------------------------
# Passing a pipe as an argumento to be executed is much harder than I thought... How to fix?

#if [[ $(which 7z) ]]; then
#    algo="7z (7z + tar)"
#    outfile="$baseout.tar.7z"
#    command=("tar" "--absolute-names" "-cf" "-" "$to_compress" "|" "7z" "a" "-bso0" "-bsp0" "-si" "$outfile")
#    benchmark "$algo" "$outfile" "${command[@]}"
#else
#    echo "7z not found, skipping"
#fi
# --------------------------------------------------------------------------------------

if [[ $(which rar) ]]; then
    algo="rar"
    outfile="$baseout.rar"
    command=("rar" "a" "-inul" "-r" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "rar not found, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which zip) ]]; then
    algo="zip"
    outfile="$baseout.zip"
    command=("zip" "-q" "-r" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
else
    echo "zip not found, skipping"
fi
# --------------------------------------------------------------------------------------

if [[ $(which zstd) ]]; then
    algo="zstd -T0 -1"
    outfile="$baseout.tar.zst"
    command=("tar" "--absolute-names" "-I" "zstd -T0 -1" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
# --------------------------------------------------------------------------------------

    algo="zstd -T0 -3 (def.)"
    outfile="$baseout.tar.zst"
    command=("tar" "--absolute-names" "-I" "zstd -T0 -3" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
# --------------------------------------------------------------------------------------

    algo="zstd -T0 -5"
    outfile="$baseout.tar.zst"
    command=("tar" "--absolute-names" "-I" "zstd -T0 -5" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
# --------------------------------------------------------------------------------------

    algo="zstd -T0 -10"
    outfile="$baseout.tar.zst"
    command=("tar" "--absolute-names" "-I" "zstd -T0 -10" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
# --------------------------------------------------------------------------------------

    algo="zstd -T0 -15"
    outfile="$baseout.tar.zst"
    command=("tar" "--absolute-names" "-I" "zstd -T0 -15" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
# --------------------------------------------------------------------------------------

    algo="zstd -T0 -19"
    outfile="$baseout.tar.zst"
    command=("tar" "--absolute-names" "-I" "zstd -T0 -19" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
# --------------------------------------------------------------------------------------

    algo="zstd -T0 --ultra -22"
    outfile="$baseout.tar.zst"
    command=("tar" "--absolute-names" "-I" "zstd -T0 --ultra -22" "-cf" "$outfile" "$to_compress")
    benchmark "$algo" "$outfile" "${command[@]}"
# --------------------------------------------------------------------------------------
else
    echo "zstd not found, skipping"
fi

echo -e "\n\nAll tests done! Quick summary (see $res_file for details):\n"

cut -d',' -f 1,2,3,4,5 $res_file | column -s',' -t

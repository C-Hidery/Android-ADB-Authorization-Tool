#!/system/bin/sh
#手动授权&取消授权adb请求
#By Ryan Crepa q3285087232
#Usage: adb_key [-a] [-d] [-r] [-d-all] [KEY] [DEVICE]
#    -a [KEY] 授权adb,需要设备key
#    -d [DEVICE] 取消授权设备，请在后面输入设备名(可用-r参数获取设备列表)
#    -d-all 取消授权所有设备
#    -r  读取当前已授权的设备名，不需要Key文件
#Key文件一般是adbkey.pub文件
#需要ROOT权限运行
SE=$1
KEY=$2
function check_key_a() {
    if [ -e "$KEY" ]; then
        echo checking key file
    else
        echo Keys file does not exist!
        exit 1
    fi
    if [ -e /data/misc/adb/adb_keys   ];then
    if grep -q "`cat "$KEY"`" /data/misc/adb/adb_keys; then
        echo This device has been authorized, skipped!
        exit 1
    fi
    fi
}
function check_key_d() {
    if [ -e /data/misc/adb/adb_keys   ];then
    if grep -q "${KEY}" /data/misc/adb/adb_keys; then
        echo Keys detected!
    else
        echo This device is not authorized, skipped!
        exit 1
    fi
    else     
        echo System adb key not found!
        exit 1
    fi
}
function authorize() {
    KEY1=`cat "$KEY"`
    echo $KEY1 >> /data/misc/adb/adb_keys
    test $? == 0 && echo OK! && exit 0 || echo Failed && exit 1
}
function unauthorize() {
TARGET_FILE="/data/misc/adb/adb_keys"
SEARCH_TEXT=$KEY
if [ -z "$SEARCH_TEXT" ]; then
     echo "Error: Empty character"
     exit 1
fi
# 转义特殊字符（/ . * 等）
ESCAPED_TEXT=$(echo "$SEARCH_TEXT" | sed 's/[\/&]/\\&/g; s/\./\\./g; s/\*/\\*/g')

# 使用 # 作为分隔符执行删除
sed -i "/^.*= ${ESCAPED_TEXT}$/d" "$TARGET_FILE" 2>/dev/null || {
  # 如果失败，改用临时文件方案
  sed "/^.*= ${ESCAPED_TEXT}$/d" "$TARGET_FILE" > "$TARGET_FILE.tmp" &&
  mv "$TARGET_FILE.tmp" "$TARGET_FILE"
}
echo OK!
}
function read_devices() {

# 读取文件并提取 = 后的内容存入数组
contents=($(sed 's/.*=//' /data/misc/adb/adb_keys))

# 打印数组内容
for item in "${contents[@]}"; do
    echo "$item"
done
}
if [ $SE = "-a" ] 2>/dev/null; then
    check_key_a
    echo Authorizing && authorize
else 
    if [ $SE = "-d" ] 2>/dev/null; then
        check_key_d
        echo Unauthorizing && unauthorize
    else
        if [ $SE = "-r" ] 2>/dev/null; then
            echo ---List of authorized devices
            read_devices
        else
            if [ $SE = "-d-all" ] 2>/dev/null; then
                read -p "Are you sure you will delete all devices authorized(y/n)?" repo
                [ ${repo} == "y" ] && rm -rf /data/misc/adb/adb_keys && echo "done"
            else
                echo Usage: adb_key [-a] [-d] [-r] [-d-all] [KEY] [DEVICE]
                echo "    -a [KEY] authorize the device"
                echo "    -d [DEVICE] unauthorize the device"
                echo "    -r  read list of authorized devices"
                echo "    -d-all  delete all devices authorized"
                exit 1
            fi
        fi
    fi
fi
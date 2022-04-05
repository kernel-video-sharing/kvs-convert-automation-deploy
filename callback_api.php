<?php
/**

@Home https://github.com/kernel-video-sharing/kvs-convert-automation-deploy

**/
require_once '../include/setup.php';
require_once '../include/functions.php';
require_once '../include/functions_base.php';

$PASS = "123456"; // 修改下

$key = $_REQUEST['key'] ?? false;
if($key != $PASS)  die('error');
$ip=$_REQUEST['ip'];
$pass=$_REQUEST['pass'];
$sql = "INSERT INTO `ktvs_admin_conversion_servers` (`server_id`, `title`, `status_id`, `connection_type_id`, `max_tasks`, `task_types`, `is_allow_any_tasks`, `process_priority`, `option_storage_servers`, `option_pull_source_files`, `path`, `ftp_host`, `ftp_port`, `ftp_user`, `ftp_pass`, `ftp_folder`, `ftp_timeout`, `ftp_force_ssl`, `error_id`, `error_iteration`, `load`, `total_space`, `free_space`, `heartbeat_date`, `api_version`, `added_date`, `is_debug_enabled`) VALUES";
$i = $_REQUEST["num"] ?? 5;
$i = $i+1;
$status_id = 1;  // 0 停止，1 有效
while($i--) {
    if($i == 0 ) continue;
    $sql .= "(NULL, '#NAME#', {$status_id}, 2, 5, 'a:0:{}', 1, 0, 1, 1, '', '#IP#', '21', 'convert', '#PASS#', '/{$i}', '20', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', '', '2022-02-16 19:43:06', 0)";
    $sql .= ($i==1) ? ";" : "," .PHP_EOL;
}
$title = str_replace(".","_",$ip);
$sql = str_replace("#NAME#","workflow_".$title,$sql);
$sql = str_replace("#IP#",$ip,$sql);
$sql = str_replace("#PASS#",$pass,$sql);
//echo $sql;
sql_insert($sql);
echo "success".PHP_EOL;

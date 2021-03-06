#Write-Host "Please" -NoNewLine -ForegroundColor Cyan

az login --output none 

[int]$numusersstart = Read-Host -Prompt 'Enter the starting number for users to remove'
[int]$numusers = Read-Host -Prompt 'Enter number of users to remove'
[string]$orgname = Read-Host -Prompt 'Enter the name of the ADO org to remove users from'

$org="https://dev.azure.com/" + $orgname

$outfilename = (Get-Date).ToString("yyyyMMdd-hhmm") + ".$orgname" + ".output.txt"

$Date = Get-Date
Write-Host "Beginning: '$numusers' users will be removed from org '$org' on '$Date'" -ForegroundColor Cyan

$tcount = $numusers
for([int]$i=0;$i -lt $numusers; $i++){
    $usernumber=($numusersstart + $i)

    $username="User" + $usernumber + "@someurl.com"
    $count = $i+1

    $pcomplete = ($i / $tcount) * 100
    Write-Progress -Activity "Removing users from ADO org $orgname" -Status "Creating user $count of $numusers" -PercentComplete $pcomplete

    az devops user remove --user $username --detect false --org $org --yes >>$outfilename

    if (!$?) {
        Write-Host "ERROR - Script is ending! Last user attempted was $username." -ForegroundColor Red
        Exit 1
    }
   
 }

 $Date = Get-Date
 Write-Host "Completed: '$count' users were created in org '$org' on '$Date'" -ForegroundColor Cyan
 Write-Host "Completed: Last user created was $username" -ForegroundColor Cyan

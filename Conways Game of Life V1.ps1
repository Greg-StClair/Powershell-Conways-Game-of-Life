#Conway's Game of Life Take1 
#Posh 7.1

#TODO: Create an alive/dead count
#TODO: Create a Board Title/Seed

$myXrange = 10 #Determines the size of the board; currently only works if the board is symmetrical.
$myYrange = 10
$playfieldSize = $myXrange * $myYrange

$coordinateGrid = [ordered]@{}
$reverseCoordinateGrid = [ordered]@{}
$cellStatus = [ordered]@{}

$currentIteration = 0 


$x = 0
$y = 0
$posCounter = -1 #start at -1 so the math isn't off by one; increments by x number are possible

###THESE GRID BOUNDS ARE WRONG, FIX THEM 

for ($xrange = 1; $xrange -le $playfieldSize; $xrange = $xrange + 1){ #Create Coordinate Grid for mapping cells
    
    $posCounter = $posCounter + 1##Name/Label of Coordinate

    $x = $x+1
    
    if(0 -eq ($x % ($myXrange+1))){$x = 1}  #increment at 7, because we want the next number to change, not the one it lands on
    
    if(0 -eq ($poscounter) % $myYrange){$y = $y + 1}

    
    $coordinateGrid += @{$posCounter = "$x,$y"} #x and y come first so that the pos number can be searched from the coordinate pair
    $reverseCoordinateGrid += @{"$x,$y" = $posCounter}

}

#$reverseCoordinateGrid
#$coordinateGrid

function findcellNeighbors($cellnumber){ #works, if the array is right :D
    #splitcoord works on the first table; we reversed it earlier so we could find the pos number from the coordinate
    $splitCoordinate = $coordinateGrid[$cellnumber] | foreach-object {$_.split(",")} 
    $xCoord = [int]$splitCoordinate[0]
    $yCoord = [int]$splitCoordinate[1]
    #Set up neighbor coordinate numbers
    $rightCheck = $xCoord + 1 #right neighbor
    $leftCheck = $xCoord - 1 #left neighbor
    $upperCheck = $yCoord + 1 # upper neighbor
    $lowerCheck = $yCoord - 1 # lower neighbor

    function neighborCoordinateFixer($coord){ 
        if($coord -eq ($myXrange+1)){ #max bound is 1 greater than $myXrange
            $coord = 1 
        }
        if($coord -eq 0){#min bound
            $coord = $myXrange
        }
        else{$coord = $coord}
        return $coord
    }

    $rightCheck = neighborCoordinateFixer($rightCheck)
    $leftCheck = neighborCoordinateFixer($leftCheck)
    $upperCheck = neighborCoordinateFixer($upperCheck)
    $lowerCheck = neighborCoordinateFixer($lowerCheck)


    #scan coordinate grid for value pairs
    $rightNeighbor = "$rightCheck,$yCoord" #no spaces, so we don't have the parse the string again
    $leftNeighbor = "$leftCheck,$yCoord"
    $upperNeighbor = "$xCoord,$upperCheck"
    $lowerNeighbor = "$xCoord,$lowerCheck"
    #Get Neighbor positions to know which ones to check for each original cell
    
    $rightNeighborPos = $reverseCoordinateGrid[$rightNeighbor]
    $leftNeighborPos = $reverseCoordinateGrid[$leftNeighbor]
    $upperNeighborPos = $reverseCoordinateGrid[$upperNeighbor]
    $lowerNeighborPos = $reverseCoordinateGrid[$lowerNeighbor]

    $cellNeighbors = @($rightNeighborPos, $leftNeighborPos, $upperNeighborPos, $lowerNeighborPos)
    ##the order is important
    return $cellNeighbors

    #Write-Host("RightNeighbor: $rightNeighborPos`n LeftNeighbor: $leftNeighborPos `nUpperNeighbor: $upperNeighborPos `nLowerNeighbor: $lowerNeighborPos `nOrigin Cell: $originalCell")
    
}
#findcellNeighbors(2) #remember arrays start at 0

$cellCount = -1
$cellState = @("alive","dead")

for ($xrange = 1; $xrange -le $playfieldSize; $xrange = $xrange + 1){ #random starting state
    $cellCount = $cellCount+1
    $random = 0,1 | Get-Random

    $cellStatus += @{"$cellCount" = $cellState[$random]}
}
#$cellStatus

#now we have alive or dead data for every generated positional, generated separately from the first array
#generate X/O based on value of $cellStatus
$global:currentIteration = 0
function drawCells(){
    
    $rowCounter = -1 
    $cellCounter = 0
    $cellCounter2 = 0
    $rowNumber = 1
    $global:aliveOrDeadList = @()

#nested for loop?
    for($xrange = 1; $xrange -le $playfieldSize; $xrange = $xrange + 1){ #distill cells into one list
        $cellCounter = $cellCounter + 1
        $cellAliveDead = $cellStatus[$cellCounter]
       
        if($cellAliveDead -eq "alive"){
            $global:aliveOrDeadList += @("O")
        }
        else{$global:aliveOrDeadList += @("X")}

      }
      #$global:aliveOrDeadList #Put after the loop so you see what it really looks like....
        for($xrange = 1; $xrange -le $playfieldSize; $xrange = $xrange + 1){ #...Then print the cells out

        $rowCounter = $rowCounter + 1

            if(0 -eq $rowCounter % $playfieldSize+1){$rowCounter = 1; $rowNumber = $rowNumber + 1}

            $cellCounter2 = $cellCounter2 + 1

        if(0 -eq $rowCounter % $myXrange){ #cuts down to six rows of text
            #something like for each row #, print chunks?

            $beginRange = $cellCounter2 - $myXrange
            $endRange = $beginRange + $myXrange - 1 #minus one because we start at 0, would print out +1 of board bounds total without
             
            #write-host ("Begin #: $beginRange, End #: $endRange, Row #: $rowCounter") #troubleshooting
            write-host $global:aliveOrDeadList[$beginRange..$endRange]

            
       
        } 
    }
    $aliveNumber = 0 
    $deadNumber = 0 
    $global:aliveOrDeadList | foreach-object {$alivedead = $_
        if($alivedead -eq "O"){
            $aliveNumber = $aliveNumber + 1
        }
        else{$deadNumber = $deadNumber + 1}
    }
    
    $global:currentIteration = $global:currentIteration + 1
     
    write-host("Alive: $aliveNumber, Dead: $deadNumber, Iterations: $currentIteration") ##Insert a new line for readability, maybe add generation numbers and seed info 
    Write-Host ""

    If($deadNumber -gt ($playfieldSize*.8)){
        Start-Sleep 5
        Write-Host "MASS DIE OFF!"
    }
}

#findcellNeighbors 1
drawCells
#this draws initial state/previous code sets world state
#now that the board is drawn... get neighbors, then redraw the board. 

function updateCellStatus(){

for ($xrange = 1; $xrange -le $playfieldSize; $xrange = $xrange + 1){
    $neighborIndex = $xrange - 1 #neighborindex is the original cell we are changing
    $cellNeighbors = findcellNeighbors $neighborindex
    $cellNeighborStatus = $cellStatus[$cellNeighbors] ##remove multiple index? 

    $aliveCount = 0
    $deadCount = 0


        ###Find number of alive vs dead cell neighbors -- THIS WORKS, integer value of living/dead neighbors
        $cellNeighborStatus | foreach-Object {
            $status = $_
            if($status -eq "alive"){$aliveCount = $aliveCount + 1}
            else{$deadCount = $deadCount + 1}       
        }
        
        ### Set Rules for changing cell state
        if($aliveCount -le 1){ 
            $cellStatus[$neighborIndex] = $cellState[1]         #Where 0 is alive, 1 is dead. 1 or less neighbors, cell dies
        }
        if($aliveCount -eq 2 -or $aliveCount -eq 3){            # Live cell with two or three neighbors continues living
            $cellStatus[$neighborIndex] = $cellState[0]
        } 
        if($aliveCount -eq 4){                                  #Any live cell with 4 neighbors dies
            $cellStatus[$neighborIndex] = $cellState[1]
        }
        if($aliveCount -eq 3 -and $cellStatus[$neighborIndex] -eq "dead"){ # Any dead cell with three neighbors comes back to life. 
            $cellStatus[$neighborIndex] = $cellState[0]
        }
    }
}


for($iterations = 1; $iterations -le 1000; $iterations ++){
updateCellStatus
drawCells

}












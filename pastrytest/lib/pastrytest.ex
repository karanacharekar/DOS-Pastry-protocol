defmodule Pastrytest do
 

  def main(args) do

    input_val = parse_args(args)



    list = getNodeList(input_val)

    IO.inspect list

    #IO.inspect getZeroes(25,"")

  end

  def getBitCount do

    bitCount = 5

    bitCount 

  end

  def parse_args(args) do

    {_, [input], _} = OptionParser.parse(args)

    #IO.inspect input

    {input_val,_} = Integer.parse(input)

    #IO.inspect input_val

    input_val

  end

  

  def generateNodeId(n) do

    Integer.to_string(round(:math.pow(2,getBitCount)),2)

    

  end



  def getNodeList(n) do

    interval =  round(:math.floor(:math.pow(2,getBitCount)/n))

    generateList(n,interval,0,[])

  end



  def generateList(n,interval,curid,nodeList) do

    #ewe

    cur = Integer.to_string(curid,16)

    #IO.puts cur

    cur = convertTo32bits(cur)

    IO.puts cur

    nodeList = [curid | nodeList]

    if( n > 1 ) do

      nodeList = generateList(n-1,interval,curid+interval,nodeList)

    end

      

    nodeList 

  end



  def convertTo32bits(str) do

     getZeroes(getBitCount/4 - String.length(str),"") <> str

     

  end

  

  def getZeroes(n,str) do

     if(n>0) do

       str = getZeroes(n-1,str <> "0")

     end

     str

  end


  def iter(route_table,rows,nodelist,nodeid) when rows > -1 do 
    Map.put(route_table,rows,[])
    choice = ["A","B","C","D","E","F","0","1","2","3","4","5","6","7","8","9"]
    
    if rows!=0 do
    Enum.each nodelist, fn x ->
    choice = List.delete(choice,String.at(nodeid,rows))
    if String.slice(x,0..rows-1) == String.slice(nodeid,0..rows-1) do
      char = String.at(x,rows)
      if Enum.member?(choice,char) do
        list = Map.get(route_table,rows)
        list = list ++ [x]
        Map.put(route_table,rows,x)
        choice = List.delete(choice,char)
      end
    end
    end
    

    else
    Enum.each nodelist, fn x ->
    choice = List.delete(choice,String.at(x,rows))
    if String.first(x) != String.first(nodeid) do
      char = String.first(x)
      if Enum.member?(choice,char) do
        list = Map.get(route_table,rows)
        list = list ++ [x]
        Map.put(route_table,rows,list)
        List.delete(choice,char)
      end  
    end
    end
    iter(route_table,rows-1,nodelist,nodeid) 

    route_table
  end

  def generate_routing_table(numnodes,nodeid,nodelist) do
    rows = Float.ceil(:math.log(numnodes)/:math.log(16)) 
    route_table = %{}
    fin_route_table = iter(route_table,rows-1,nodelist,nodeid)    
  end

end
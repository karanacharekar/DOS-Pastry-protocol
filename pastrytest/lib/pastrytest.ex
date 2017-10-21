defmodule Pastrytest do
 
def main(args) do

    input_val = parse_args(args)



    list = getNodeList(input_val)
    node_id = "0"
    #IO.inspect list

    IO.puts "file hash :: " <> getFileHash("keyur file")

    #IO.inspect getZeroes(25,"")
    generate_routing_table(input_val,node_id,list)
  end

  def getBitCount do

    bitCount = 4

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

    interval =  round(:math.floor(getNodeSpace/n))

    generateList(n,interval,0,[])

  end



  def generateList(n,interval,curid,nodeList) do

    #ewe

    cur = Integer.to_string(curid,16)

    #IO.puts cur

    cur = convertTo32bits(cur)

    IO.puts cur



    nodeList = [cur | nodeList]

    

    if( n > 1 ) do

      interval = round(:math.floor((getNodeSpace - curid - 1)/(n-1)))

      nodeList = generateList(n-1,interval,curid+interval,nodeList)

    end

      

    nodeList 

  end



  def convertTo32bits(str) do

     getZeroes(getBitCount/4 - String.length(str),"") <> str

     

  end



  def getNodeSpace do

    :math.pow(2,getBitCount)

  end

  

  def getZeroes(n,str) do

     if(n>0) do

       str = getZeroes(n-1,str <> "0")

     end

     str

  end



  def getFileHash(filename) do
    String.slice(Base.encode16(:crypto.hash(:sha256, filename)),0,round(getBitCount/4))
  end


  def iter(route_table,rows,nodelist,nodeid)   do 
    #IO.inspect rows
    if(rows < 0) do 
      route_table
    else
    route_table = Map.put(route_table,rows,[])
    choice = ["A","B","C","D","E","F","0","1","2","3","4","5","6","7","8","9"]
    #IO.inspect route_table  
    if rows != 0 do
    IO.puts "helooooooooo"
    Enum.each nodelist, fn x ->
    choice = List.delete(choice,String.at(nodeid,rows))
    if String.slice(x,0..rows-1) == String.slice(nodeid,0..rows-1) do
      char = String.at(x,rows)
      if Enum.member?(choice,char) do
        list = Map.get(route_table,rows)
        list = list ++ [x]
        route_table = Map.put(route_table,rows,x)
        choice = List.delete(choice,char)
      end
    end
    end
    

    else
    IO.inspect rows
    IO.inspect route_table
    IO.puts "karannnnnnn"
    Enum.each nodelist, fn x ->
    choice = List.delete(choice,String.at(x,rows))
    #IO.inspect choice
    if String.first(x) != String.first(nodeid) do
      IO.inspect choice
      char = String.first(x)
      if Enum.member?(choice,char) do
        list = Map.get(route_table,rows)
        list = list ++ [x]
        route_table = Map.put(route_table,rows,list)
        IO.inspect route_table
        choice = List.delete(choice,char)
      end  
    end
    end
    iter(route_table,rows-1,Enum.shuffle(nodelist),nodeid) 
    route_table
  end
  end
  end

  


  def generate_routing_table(numnodes,nodeid,nodelist) do
    rows = round(Float.ceil(:math.log(numnodes)/:math.log(16))) 
    route_table = %{}
    fin_route_table = iter(route_table,rows-1,nodelist,nodeid)  
    IO.puts "here"
    IO.inspect fin_route_table
  end

end
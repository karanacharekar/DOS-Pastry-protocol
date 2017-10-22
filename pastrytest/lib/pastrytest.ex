defmodule Pastrytest do
 
def main(args) do

    input_val = parse_args(args)
    list = getNodeList(input_val)
    node_id = "000"
    #IO.inspect list

    IO.puts "file hash :: " <> getFileHash("keyur file")

    #IO.inspect getZeroes(25,"")
    generate_routing_table(input_val,node_id,list)
  end

  def getBitCount do

    bitCount = 12

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
        route_table_new = generator123(nodeid,nodelist,route_table,rows,choice)  
        route_table_new=iter(route_table_new,rows-1,Enum.shuffle(nodelist),nodeid) 
        route_table_new

        else
        IO.inspect rows
        IO.inspect route_table
        IO.puts "karannnnnnn"


        route_table_new = generator0(nodeid,nodelist,route_table,rows,choice)  
        route_table_new=iter(route_table_new,rows-1,Enum.shuffle(nodelist),nodeid) 
        route_table_new
    end
  end
  end



  
  def generator0(nodeid,nodelist,route_table,rows,choice) do
    #IO.inspect route_table
    if length(nodelist) !=0 do
    [x|nodelistrest] = nodelist
    #IO.puts "----"
    #IO.inspect String.at(x,rows)
    choice = List.delete(choice,String.at(nodeid,rows))
    #IO.inspect choice
    if String.first(x) != String.first(nodeid) do
      #IO.inspect choice
      char = String.first(x)
      #IO.puts char
      #IO.inspect choice
      if Enum.member?(choice,char) do
        #Io.puts "thissss"
        list = Map.get(route_table,rows)
        list = list ++ [x]
        route_table = Map.put(route_table,rows,list)
        #IO.inspect route_table
        choice = List.delete(choice,char)
      end  
    end

    generator0(nodeid,nodelistrest,route_table,rows,choice) 

    else
    IO.puts "heloo"
    IO.inspect route_table

    route_table
    end
    end


    def generator123(nodeid,nodelist,route_table,rows,choice) do
    #IO.inspect route_table
    if length(nodelist) !=0 do
    [x|nodelistrest] = nodelist
    #IO.puts "----"
    #IO.inspect String.at(x,rows)
    choice = List.delete(choice,String.at(nodeid,rows))
    #IO.inspect choice
    if String.slice(x,0..rows-1) == String.slice(nodeid,0..rows-1) do
      #IO.inspect choice
      char = String.at(x,rows)
      #IO.puts char
      #IO.inspect choice
      if Enum.member?(choice,char) do
        #Io.puts "thissss"
        list = Map.get(route_table,rows)
        list = list ++ [x]
        route_table = Map.put(route_table,rows,list)
        #IO.inspect route_table
        choice = List.delete(choice,char)
      end  
    end

    generator123(nodeid,nodelistrest,route_table,rows,choice) 

    else
    IO.puts "heloo"
    IO.inspect route_table

    route_table
    end
    end



  def generate_routing_table(numnodes,nodeid,nodelist) do
    rows = round(Float.ceil(:math.log(numnodes)/:math.log(16))) 
    route_table = %{}
    IO.puts "---------------"
    IO.puts rows
    fin_route_table = iter(route_table,rows-1,nodelist,nodeid)  
    IO.puts "here"
    IO.inspect fin_route_table


    #leaf_map = %{}
    distance_list = create_leaf_set(nodeid,nodelist,[])
    distance_list_sorted = Enum.sort(distance_list)
    num_leafs = round(:math.pow(2,4)/2)
    zero_index = Enum.find_index(distance_list, fn(x) -> x==0 end)
    count_larger_set = zero_index + num_leafs
    count_smaller_set = zero_index - num_leafs
    larger_list = generate_larger_leafset(nodeid,zero_index,distance_list_sorted,count_larger_set,[])
    smaller_list = generate_smaller_leafset(nodeid,zero_index,distance_list_sorted,count_smaller_set,[])
    all_leaves = smaller_list ++ larger_list
    IO.inspect all_leaves
    fin_route_table = Map.put(fin_route_table,"leaf_set",all_leaves)
    IO.inspect fin_route_table
  end


  
  def generate_larger_leafset(nodeid,zero_index,distance_list_sorted,count_larger_set,larger_list) do
  
    IO.inspect distance_list_sorted
    if  count_larger_set > zero_index do
      
      val = Enum.at(distance_list_sorted,count_larger_set)
      if val != nil do
        IO.puts "val is"
        IO.inspect val
        nodeid_val = String.to_integer(nodeid,16)
        IO.puts "node id val is "
        IO.inspect nodeid_val
        curr_node_val = nodeid_val - val
        curr_node = Integer.to_string(curr_node_val,16)
        larger_list = larger_list ++ [curr_node]
        generate_larger_leafset(nodeid,zero_index,distance_list_sorted,count_larger_set-1,larger_list)
      else
        generate_larger_leafset(nodeid,zero_index,distance_list_sorted,count_larger_set-1,larger_list)
      end
    else
      larger_list
    end     


  end 


  def generate_smaller_leafset(nodeid,zero_index,distance_list_sorted, count_smaller_set,smaller_list) do
  if  count_smaller_set < zero_index do
      val = Enum.at(distance_list_sorted,count_smaller_set)
      if val !=nil do
        nodeid_val = String.to_integer(nodeid,16)
        curr_node_val = nodeid_val - val
        curr_node = Integer.to_string(curr_node_val,16)
        smaller_list = smaller_list ++ [curr_node]
        generate_smaller_leafset(nodeid,zero_index,distance_list_sorted,count_smaller_set+1,smaller_list)
      else  
        generate_smaller_leafset(nodeid,zero_index,distance_list_sorted,count_smaller_set+1,smaller_list)
      end
    else
      smaller_list
    end   

  end 



def create_leaf_set(nodeid,nodelist,distance_list) do
    if length(nodelist) != 0 do
        [curr_node| rest_list] = nodelist
        intval_curr = String.to_integer(curr_node,16)
        intval_nodeid =  String.to_integer(nodeid,16)
        diff =  intval_nodeid - intval_curr
        distance_list = distance_list ++ [diff]
        create_leaf_set(nodeid,rest_list,distance_list)  

    else
        distance_list
    end

end

end
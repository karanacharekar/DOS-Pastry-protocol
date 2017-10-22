defmodule Pastrytest do
 
def main(args) do
    args |> parse_args 
    
  end

  def getBitCount do
    bitCount = 128
    bitCount 
  end

  def parse_args(args) do
    {_, [input,requests], _} = OptionParser.parse(args)
    

    input_valss = Integer.parse(input)
    input_val = elem(input_valss,0)
    numrequestss = Integer.parse(requests)
    numrequests = elem(numrequestss,0)
    
    #IO.inspect numrequests
    #IO.inspect input_val

    #IO.puts "-------------------------------"

    list = getNodeList(input_val)
    file_list = get_files(numrequests,[])
    #IO.puts "file list is this"
    #IO.inspect file_list
    create_nodes(list,list,input_val)
    #IO.puts " all is done"
    #IO.puts "file hash :: " <> getFileHash("aanima file")
    #fileHash = getFileHash("aanima file")
    #fileHash = "9E4C"
    hop_counter(list,file_list)
    #IO.puts " i am hereeeeeeeeeeeeeeeeeeeeeee" 
    all_hops = getaveragehops(list,0)
    avgnumhops = all_hops/(length(list)*length(file_list))
    IO.puts "Avg number of hops are"
    IO.inspect avgnumhops
    #startNode = Enum.random(list)
    #send_message(startNode,fileHash)
    IO.gets ""
  end


 
  def getaveragehops(nodelist,avghops) do
    if length(nodelist) != 0 do
      [curr_node|rest_list] = nodelist
      state =  GenServer.call(String.to_atom(curr_node),{:get_state, "getstate"}) 
      count = Map.get(state,"count")
      #IO.inspect count
      #IO.inspect Enum.sum(count)
      avghops = avghops + Enum.sum(count)
      getaveragehops(rest_list,avghops)
    else
      avghops  
    end

  end 

  def hop_counter(nodelist,file_list) do
     Enum.each(nodelist, fn(n) ->
        curr_node = n 
        Enum.each(file_list, fn(f) ->
            curr_file = f
            #IO.puts "-------------"
            #IO.inspect curr_node
            #IO.inspect curr_file
            send_message(curr_node,curr_node,curr_file,0)
        end)
     end)
  end


  def get_files(num,list) do
    if num > 0 do
        string = :crypto.strong_rand_bytes(30) |> Base.url_encode64
        fileHash = getFileHash(string)
        list = list ++ [fileHash]
        get_files(num-1,list) 
    else
        list
    end
  end

  def create_nodes(nodelist,nodelistfull,numnodes) do
    if length(nodelist) !=0 do
      [curr_node|rest_list] = nodelist
      GenServer.start_link(__MODULE__, {curr_node,numnodes,nodelistfull}, name: String.to_atom(curr_node))
      create_nodes(rest_list,nodelistfull,numnodes)
    end
  end

  def init(args) do
    nodeid = elem(args,0)
    numnodes = elem(args,1)
    nodelist = elem(args,2)
    state = generate_routing_table(numnodes,nodeid,nodelist)
    state = Map.put(state,"node_id",nodeid)
    state = Map.put(state,"count",[])
    #IO.puts "-------------------------"
    #IO.inspect nodeid
    #IO.inspect state
    #IO.puts "-------------------------"
    {:ok,state}
  end


  def generateNodeId(n) do
    Integer.to_string(round(:math.pow(2,getBitCount)),2)
  end


  def getNodeList(n) do
    interval =  round(:math.floor(getNodeSpace/n))
    generateList(n,interval,0,[])
  end


  def generateList(n,interval,curid,nodeList) do
    cur = Integer.to_string(curid,16)
    cur = convertTo32bits(cur)
    #IO.puts cur
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
    if(rows < 0) do 
      route_table
    else
    route_table = Map.put(route_table,rows,[])
    choice = ["A","B","C","D","E","F","0","1","2","3","4","5","6","7","8","9"]
        if rows != 0 do
          route_table_new = generator123(nodeid,nodelist,route_table,rows,choice)  
          route_table_new=iter(route_table_new,rows-1,Enum.shuffle(nodelist),nodeid) 
          route_table_new
        else
          route_table_new = generator0(nodeid,nodelist,route_table,rows,choice)  
          route_table_new=iter(route_table_new,rows-1,Enum.shuffle(nodelist),nodeid) 
          route_table_new
        end
    end
  end



  
  def generator0(nodeid,nodelist,route_table,rows,choice) do
    if length(nodelist) !=0 do
    [x|nodelistrest] = nodelist
    choice = List.delete(choice,String.at(nodeid,rows))
    if String.first(x) != String.first(nodeid) do
      char = String.first(x)
      if Enum.member?(choice,char) do
        list = Map.get(route_table,rows)
        list = list ++ [x]
        route_table = Map.put(route_table,rows,list)
        choice = List.delete(choice,char)
      end  
    end

    generator0(nodeid,nodelistrest,route_table,rows,choice) 

    else
      route_table
    end
    end


    def generator123(nodeid,nodelist,route_table,rows,choice) do
    if length(nodelist) !=0 do
    [x|nodelistrest] = nodelist
    choice = List.delete(choice,String.at(nodeid,rows))
    if String.slice(x,0..rows-1) == String.slice(nodeid,0..rows-1) do
      char = String.at(x,rows)
      if Enum.member?(choice,char) do
        list = Map.get(route_table,rows)
        list = list ++ [x]
        route_table = Map.put(route_table,rows,list)
        choice = List.delete(choice,char)
      end  
    end

    generator123(nodeid,nodelistrest,route_table,rows,choice) 

    else
      route_table
    end
    end



  def generate_routing_table(numnodes,nodeid,nodelist) do
    rows = round(Float.ceil(:math.log(numnodes)/:math.log(16))) 
    route_table = %{}

    fin_route_table = iter(route_table,rows-1,nodelist,nodeid)  

    distance_list = create_leaf_set(nodeid,nodelist,[])
    distance_list_sorted = Enum.sort(distance_list)
    num_leafs = round(:math.pow(2,4)/2)
    zero_index = Enum.find_index(distance_list, fn(x) -> x==0 end)
    count_larger_set = zero_index + num_leafs
    count_smaller_set = zero_index - num_leafs
    larger_list = generate_larger_leafset(nodeid,zero_index,distance_list_sorted,count_larger_set,[])
    smaller_list = generate_smaller_leafset(nodeid,zero_index,distance_list_sorted,count_smaller_set,[])
    all_leaves = smaller_list ++ larger_list

    fin_route_table = Map.put(fin_route_table,"leaf_set",all_leaves)

    fin_route_table
  end


  
  def generate_larger_leafset(nodeid,zero_index,distance_list_sorted,count_larger_set,larger_list) do

    if  count_larger_set > zero_index do
      
      val = Enum.at(distance_list_sorted,count_larger_set)
      if val != nil do
        nodeid_val = String.to_integer(nodeid,16)
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




def string_compare(fileHash,curr_node,prefixLength) do
    if String.at(fileHash,prefixLength) == String.at(curr_node,prefixLength) do
        string_compare(fileHash,curr_node,prefixLength+1)
    else
        prefixLength
    end
end


def send_message(source_node,neighbourId,fileHash,hopcount) do
      start_node_name = neighbourId
      spawn fn -> GenServer.call(String.to_atom(start_node_name),{:receive_msg,{source_node,fileHash,hopcount}}) end
end

  ##server cal;backs
 
def iter_neighbours(neighbor,full_list,fileHash,row,curr) do
      if length(neighbor)>0 do
          [first|rest_list] = neighbor
          #IO.puts "firstis"
          #IO.inspect first
          #IO.puts "file is "
          #IO.inspect fileHash
          if String.at(first,row) == String.at(fileHash,row) do
              {first,"notend"}
          else
              #IO.inspect rest_list
              iter_neighbours(rest_list,full_list,fileHash,row,curr)
          end 
      else
          new_list = full_list ++ [curr]
          #IO.puts "== === =="
          #IO.inspect new_list
          dist = %{}
          nearestnodemap = getNearestNodeId(new_list,fileHash,dist)
          #IO.inspect nearestnodemap
          keys = Map.keys(nearestnodemap)
          keys = Enum.sort(keys)
          #IO.inspect keys
          nearestnodeid = List.first(keys)
          #IO.inspect nearestnodeid
          nearestnode = Map.get(nearestnodemap,nearestnodeid)
          #IO.inspect nearestnode
          {nearestnode,"end"}
      end
  end

  def handle_call({:receive_msg ,new_message}, _from,state) do
    
    source_node = elem(new_message,0)
    fileHash = elem(new_message,1)
    hopcount = elem(new_message,2)
    curr_node = Map.get(state,"node_id")
    #IO.puts "curr node is"
    #IO.inspect curr_node
    row = string_compare(fileHash,curr_node,0)
    #IO.puts "rows is "
    #IO.inspect row
    #IO.puts "filehash is"
    #IO.inspect fileHash
    neighbour = Map.get(state,row)
    #IO.puts "neighbr is"
    #IO.inspect neighbour
    
    if neighbour != nil do
      hopcount = hopcount+1
      {next_neighbour,condi} = iter_neighbours(neighbour,neighbour,fileHash,row,curr_node)
    else
        #IO.puts "nearest neigbour is "
        #IO.inspect curr_node
        spawn fn -> GenServer.call(String.to_atom(source_node),{:update_count_list,{hopcount}}) end

    end
  
    if condi == "end" do
        #IO.puts "nearest neighbour is" 
        #IO.puts next_neighbour
        spawn fn -> GenServer.call(String.to_atom(source_node),{:update_count_list,{hopcount}}) end
    end

    if condi == "notend" do
        send_message(source_node,next_neighbour,fileHash,hopcount)
    end
    {:reply, state, state}   
  end


def getNearestNodeId(neighbour,fileHash,dist) do
    if length(neighbour) > 0 do
        [head|rest_list] = neighbour
        head_val = String.to_integer(head,16)
        fileHash_val = String.to_integer(fileHash,16)
        dist = Map.put(dist,Kernel.abs(head_val-fileHash_val),head)
        getNearestNodeId(rest_list,fileHash,dist)
    else
      dist
    end  
end


def handle_call({:get_state ,new_message},_from,state) do  
    {:reply,state,state}
end

def handle_call({:update_count_list ,new_message},_from,state) do  
     count = elem(new_message,0)
     #state = GenServer.call(String.to_atom(curr_node),{:get_state, "getstate"})   
     countlist = Map.get(state,"count")
     countlist = countlist ++ [count]  
     state = Map.put(state,"count",countlist)  
     {:reply,state,state}
end



end
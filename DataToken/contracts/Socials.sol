pragma solidity 0.8.0;
import "./interfaces/INFT.sol";
import "./interfaces/IERCReceiver.sol";
import "./Dependencies/Ownable.sol";



contract socialMedia is Ownable{

    INFT public immutable  Profile;
    uint postId;

    struct POSTS{
        uint id;
        bytes post;
    }

    POSTS [] public allPost;

    constructor (INFT _Profile){
        Profile=_Profile;
    }
    
    event profileCreated(bytes tokenId, address owner, string name, uint time);
    event ProfileUpdated(bytes tokenId, address owner, string name, uint time);
    event BioCreated(string bio, address owner, uint time );
    event updateBio(string Newbio, address owner, uint time );
    event postCreated (address sender, bytes post, uint256 time, uint postId);
    event commented(uint index, bytes post);
    event postDeleted();
    

    function createPost(string calldata post) external returns (bytes memory){
        uint time=block.timestamp;
        address sender=msg.sender;
        bytes memory Post=abi.encode(post);
        postId++;
        allPost.push(POSTS(postId, Post));
        emit postCreated (sender, Post, time, postId);
        return Post;
         
        

    }

    



    function deletePost(bytes calldata tokenId, uint index)external{
        Profile.burn(tokenId);
        delete allPost[index];
    }

    function decodePost(bytes memory data) public pure returns (string memory post) {
        (post) = abi.decode(data, (string));            
    }


    function mintAprofile(string calldata name, address to)public{
        Profile.safeMint(name, to);

    }

    function UpdateAprofile(bytes calldata oldTokenId, string calldata Newname, address to) onlyOwner public{
        Profile.burn(oldTokenId);
        Profile.safeMint(Newname, to);
    }

    function mintABio(string calldata bio, address to) public{
        uint time=block.timestamp;
        Profile.safeMint(bio, to);
        emit BioCreated( bio, to, time ); 
    }

    function UpdateABio(bytes calldata oldTokenId, string calldata NewBio, address to) onlyOwner public{
       uint time=block.timestamp;
        Profile.burn(oldTokenId);
        Profile.safeMint(NewBio, to);
        emit updateBio( NewBio, to,  time );
    }

    function getPost(uint index) public view returns (uint, bytes memory) {
        POSTS storage _post=allPost[index];
        return (_post.id, _post.post);
    }

    
    function totalPost()public view returns (uint totalPostsMade){
        return allPost.length;
    }


    function onERCReceived(
        address,
        address from,
        bytes calldata,
        bytes calldata
    ) external pure returns (bytes4) {
      require(from == address(0x0), "Cannot send nfts to Vault directly");
      return IERCReceiver.onERCReceived.selector;
    }
    



}
pragma solidity 0.8.0;
import "./interfaces/IERCReceiver.sol";
import "./ERC.sol";
import "./Dependencies/Ownable.sol";



contract socialMedia is Ownable, ERC{

    uint postId;
    uint commentId;

    struct POSTS{
        address Poster;
        uint Id;
        string post;
    }

    struct COMMENTS{
        address Commenter;
        uint Id;
        string comment;
    }

    POSTS [] public allPost;
    COMMENTS [] public allComment;

    constructor ()ERC("socialMedia", "SMA"){
        
    }
    
    event profileCreated(bytes indexed tokenId, address indexed owner, string indexed name, uint time);
    event ProfileUpdated(bytes indexed tokenId, address indexed owner, string indexed name, uint time);
    event BioCreated(string indexed bio, address indexed owner, uint time );
    event updateBio(string indexed Newbio, address indexed owner, uint time );
    event postCreated (address indexed sender, string indexed post, uint256 time, uint indexed postId);
    event postDeleted(bytes indexed tokenId, uint indexed index);
    event commented(address indexed postedBy, address indexed commentBy, string indexed commentedOn, string indexedcomment, uint commentId, uint time);
    

    function createPost(string calldata post) external{
        uint time=block.timestamp;
        address sender=msg.sender;
        //bytes memory Post=abi.encode(post);
        postId++;
        allPost.push(POSTS(sender,postId, post));
        emit postCreated (sender, post, time, postId);   

    }

    /*function createPost(string calldata post) external {
        postId++;
        address to=msg.sender;
        bytes memory newtokenId=(abi.encode(post));
        _safeMint(to, newtokenId);
        allPost.push(POSTS(postId, newtokenId));
    }*/

    function commentOnPost(uint index, string calldata comment)public{
        uint time=block.timestamp;
        address commentBy=msg.sender;
        commentId++;
        POSTS storage _post=allPost[index];
        string memory commentedOn= _post.post;
        address postedBy= _post.Poster;
        allComment.push(COMMENTS(commentBy, commentId, comment));
        emit commented(postedBy, commentBy, commentedOn, comment, commentId, time);
        

    }

    function deletePost(bytes calldata tokenId, uint index)external{
        _burn(tokenId);
        delete allPost[index];
        emit postDeleted(tokenId, index);
    }

    function decodePost(bytes memory data) public pure returns (string memory post) {
        (post) = abi.decode(data, (string));            
    }


    function mintAprofile(string calldata name, address to)public{
        uint time=block.timestamp;
        bytes memory tokenId=(abi.encode(name, to,  time));
        _safeMint(to, tokenId);
        emit profileCreated(tokenId, to, name, time);
        

    }

    function UpdateAprofile(bytes calldata oldTokenId, string calldata newName, address to) onlyOwner public{
        _burn(oldTokenId);
        uint time=block.timestamp;
        bytes memory newTokenId=(abi.encode(oldTokenId, newName, to, time));
        _safeMint(to, newTokenId );
        emit ProfileUpdated(newTokenId, to, newName, time);
    }

    function mintABio(string calldata bio, address to) public{
        uint time=block.timestamp;
        bytes memory tokenId=(abi.encode(bio, to, time));
        _safeMint(to, tokenId);
        emit BioCreated( bio, to, time ); 
    }

    function UpdateABio(bytes calldata oldTokenId, string calldata newBio, address to) onlyOwner public{
       _burn(oldTokenId);
        uint time=block.timestamp;
        bytes memory newTokenId=(abi.encode(oldTokenId, newBio, to, time));
        _safeMint(to, newTokenId );
        emit updateBio( newBio, to,  time );
    }

    function getPost(uint index) public view returns (address, uint, string memory) {
        POSTS storage _post=allPost[index];
        return (_post.Poster, _post.Id, _post.post);
    }

    function getcomment(uint index) public view returns (address, uint, string memory) {
        COMMENTS storage _comment=allComment[index];
        return (_comment.Commenter, _comment.Id, _comment.comment);
    }

    
    function totalPost()public view returns (uint totalPostsMade){
        return allPost.length;
    }


    function onERC721Received(
        address,
        address from,
        bytes calldata,
        bytes calldata
    ) external pure returns (bytes4) {
      require(from == address(0x0), "Cannot send nfts to Vault directly");
      return IERCReceiver.onERCReceived.selector;
    }
    



}
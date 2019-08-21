// String Utils v0.1

/// @title String Utils - String utility functions
/// @author Piper Merriam - 
library StringLib {
    /*
     *  Address: 0x443b53559d337277373171280ec57029718203fb
     */

    /// @dev Converts an unsigned integert to its string representation.
    /// @param v The number to be converted.
    function uintToBytes(uint v) constant returns (bytes32 ret) {
        if (v == 0) {
            ret = '0';
        }
        else {
            while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }

    /// @dev Converts a numeric string to it's unsigned integer representation.
    /// @param v The string to be converted.
    function bytesToUInt(bytes32 v) constant returns (uint ret) {
        if (v == 0x0) {
            throw;
        }

        uint digit;

        for (uint i = 0; i < 32; i++) {
            digit = uint((uint(v) / (2 ** (8 * (31 - i)))) & 0xff);
            if (digit == 0) {
                break;
            }
            else if (digit < 48 || digit > 57) {
                throw;
            }
            ret *= 10;
            ret += (digit - 48);
        }
        return ret;
    }
}


// Accounting v0.1 (not the same as the 0.1 release of this library)

/// @title Accounting Lib - Accounting utilities
/// @author Piper Merriam - 
library AccountingLib {
        /*
         *  Address: 0x7de615d8a51746a9f10f72a593fb5b3718dc3d52
         */
        struct Bank {
            mapping (address => uint) accountBalances;
        }

        /// @dev Low level method for adding funds to an account.  Protects against overflow.
        /// @param self The Bank instance to operate on.
        /// @param accountAddress The address of the account the funds should be added to.
        /// @param value The amount that should be added to the account.
        function addFunds(Bank storage self, address accountAddress, uint value) public {
                if (self.accountBalances[accountAddress] + value < self.accountBalances[accountAddress]) {
                        // Prevent Overflow.
                        throw;
                }
                self.accountBalances[accountAddress] += value;
        }

        event _Deposit(address indexed _from, address indexed accountAddress, uint value);
        /// @dev Function wrapper around the _Deposit event so that it can be used by contracts.  Can be used to log a deposit to an account.
        /// @param _from The address that deposited the funds.
        /// @param accountAddress The address of the account the funds were added to.
        /// @param value The amount that was added to the account.
        function Deposit(address _from, address accountAddress, uint value) public {
            _Deposit(_from, accountAddress, value);
        }


        /// @dev Safe function for depositing funds.  Returns boolean for whether the deposit was successful
        /// @param self The Bank instance to operate on.
        /// @param accountAddress The address of the account the funds should be added to.
        /// @param value The amount that should be added to the account.
        function deposit(Bank storage self, address accountAddress, uint value) public returns (bool) {
                addFunds(self, accountAddress, value);
                return true;
        }

        event _Withdrawal(address indexed accountAddress, uint value);

        /// @dev Function wrapper around the _Withdrawal event so that it can be used by contracts.  Can be used to log a withdrawl from an account.
        /// @param accountAddress The address of the account the funds were withdrawn from.
        /// @param value The amount that was withdrawn to the account.
        function Withdrawal(address accountAddress, uint value) public {
            _Withdrawal(accountAddress, value);
        }

        event _InsufficientFunds(address indexed accountAddress, uint value, uint balance);

        /// @dev Function wrapper around the _InsufficientFunds event so that it can be used by contracts.  Can be used to log a failed withdrawl from an account.
        /// @param accountAddress The address of the account the funds were to be withdrawn from.
        /// @param value The amount that was attempted to be withdrawn from the account.
        /// @param balance The current balance of the account.
        function InsufficientFunds(address accountAddress, uint value, uint balance) public {
            _InsufficientFunds(accountAddress, value, balance);
        }

        /// @dev Low level method for removing funds from an account.  Protects against underflow.
        /// @param self The Bank instance to operate on.
        /// @param accountAddress The address of the account the funds should be deducted from.
        /// @param value The amount that should be deducted from the account.
        function deductFunds(Bank storage self, address accountAddress, uint value) public {
                /*
                 *  Helper function that should be used for any reduction of
                 *  account funds.  It has error checking to prevent
                 *  underflowing the account balance which would be REALLY bad.
                 */
                if (value > self.accountBalances[accountAddress]) {
                        // Prevent Underflow.
                        throw;
                }
                self.accountBalances[accountAddress] -= value;
        }

        /// @dev Safe function for withdrawing funds.  Returns boolean for whether the deposit was successful as well as sending the amount in ether to the account address.
        /// @param self The Bank instance to operate on.
        /// @param accountAddress The address of the account the funds should be withdrawn from.
        /// @param value The amount that should be withdrawn from the account.
        function withdraw(Bank storage self, address accountAddress, uint value) public returns (bool) {
                /*
                 *  Public API for withdrawing funds.
                 */
                if (self.accountBalances[accountAddress] >= value) {
                        deductFunds(self, accountAddress, value);
                        if (!accountAddress.send(value)) {
                                // Potentially sending money to a contract that
                                // has a fallback function.  So instead, try
                                // tranferring the funds with the call api.
                                if (!accountAddress.call.value(value)()) {
                                        // Revert the entire transaction.  No
                                        // need to destroy the funds.
                                        throw;
                                }
                        }
                        return true;
                }
                return false;
        }
}

// Grove v0.3 (not the same as the 0.3 release of this library)


/// @title GroveLib - Library for queriable indexed ordered data.
/// @author PiperMerriam - 
library GroveLib {
        /*
         *  Indexes for ordered data
         *
         *  Address: 0x920c890a90db8fba7604864b0cf38ee667331323
         */
        struct Index {
                bytes32 root;
                mapping (bytes32 => Node) nodes;
        }

        struct Node {
                bytes32 id;
                int value;
                bytes32 parent;
                bytes32 left;
                bytes32 right;
                uint height;
        }

        function max(uint a, uint b) internal returns (uint) {
            if (a >= b) {
                return a;
            }
            return b;
        }

        /*
         *  Node getters
         */
        /// @dev Retrieve the unique identifier for the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeId(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].id;
        }

        /// @dev Retrieve the value for the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeValue(Index storage index, bytes32 id) constant returns (int) {
            return index.nodes[id].value;
        }

        /// @dev Retrieve the height of the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeHeight(Index storage index, bytes32 id) constant returns (uint) {
            return index.nodes[id].height;
        }

        /// @dev Retrieve the parent id of the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeParent(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].parent;
        }

        /// @dev Retrieve the left child id of the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeLeftChild(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].left;
        }

        /// @dev Retrieve the right child id of the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeRightChild(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].right;
        }

        /// @dev Retrieve the node id of the next node in the tree.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getPreviousNode(Index storage index, bytes32 id) constant returns (bytes32) {
            Node storage currentNode = index.nodes[id];

            if (currentNode.id == 0x0) {
                // Unknown node, just return 0x0;
                return 0x0;
            }

            Node memory child;

            if (currentNode.left != 0x0) {
                // Trace left to latest child in left tree.
                child = index.nodes[currentNode.left];

                while (child.right != 0) {
                    child = index.nodes[child.right];
                }
                return child.id;
            }

            if (currentNode.parent != 0x0) {
                // Now we trace back up through parent relationships, looking
                // for a link where the child is the right child of it's
                // parent.
                Node storage parent = index.nodes[currentNode.parent];
                child = currentNode;

                while (true) {
                    if (parent.right == child.id) {
                        return parent.id;
                    }

                    if (parent.parent == 0x0) {
                        break;
                    }
                    child = parent;
                    parent = index.nodes[parent.parent];
                }
            }

            // This is the first node, and has no previous node.
            return 0x0;
        }

        /// @dev Retrieve the node id of the previous node in the tree.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNextNode(Index storage index, bytes32 id) constant returns (bytes32) {
            Node storage currentNode = index.nodes[id];

            if (currentNode.id == 0x0) {
                // Unknown node, just return 0x0;
                return 0x0;
            }

            Node memory child;

            if (currentNode.right != 0x0) {
                // Trace right to earliest child in right tree.
                child = index.nodes[currentNode.right];

                while (child.left != 0) {
                    child = index.nodes[child.left];
                }
                return child.id;
            }

            if (currentNode.parent != 0x0) {
                // if the node is the left child of it's parent, then the
                // parent is the next one.
                Node storage parent = index.nodes[currentNode.parent];
                child = currentNode;

                while (true) {
                    if (parent.left == child.id) {
                        return parent.id;
                    }

                    if (parent.parent == 0x0) {
                        break;
                    }
                    child = parent;
                    parent = index.nodes[parent.parent];
                }

                // Now we need to trace all the way up checking to see if any parent is the 
            }

            // This is the final node.
            return 0x0;
        }


        /// @dev Updates or Inserts the id into the index at its appropriate location based on the value provided.
        /// @param index The index that the node is part of.
        /// @param id The unique identifier of the data element the index node will represent.
        /// @param value The value of the data element that represents it's total ordering with respect to other elementes.
        function insert(Index storage index, bytes32 id, int value) public {
                if (index.nodes[id].id == id) {
                    // A node with this id already exists.  If the value is
                    // the same, then just return early, otherwise, remove it
                    // and reinsert it.
                    if (index.nodes[id].value == value) {
                        return;
                    }
                    remove(index, id);
                }

                uint leftHeight;
                uint rightHeight;

                bytes32 previousNodeId = 0x0;

                if (index.root == 0x0) {
                    index.root = id;
                }
                Node storage currentNode = index.nodes[index.root];

                // Do insertion
                while (true) {
                    if (currentNode.id == 0x0) {
                        // This is a new unpopulated node.
                        currentNode.id = id;
                        currentNode.parent = previousNodeId;
                        currentNode.value = value;
                        break;
                    }

                    // Set the previous node id.
                    previousNodeId = currentNode.id;

                    // The new node belongs in the right subtree
                    if (value >= currentNode.value) {
                        if (currentNode.right == 0x0) {
                            currentNode.right = id;
                        }
                        currentNode = index.nodes[currentNode.right];
                        continue;
                    }

                    // The new node belongs in the left subtree.
                    if (currentNode.left == 0x0) {
                        currentNode.left = id;
                    }
                    currentNode = index.nodes[currentNode.left];
                }

                // Rebalance the tree
                _rebalanceTree(index, currentNode.id);
        }

        /// @dev Checks whether a node for the given unique identifier exists within the given index.
        /// @param index The index that should be searched
        /// @param id The unique identifier of the data element to check for.
        function exists(Index storage index, bytes32 id) constant returns (bool) {
            return (index.nodes[id].id == id);
        }

        /// @dev Remove the node for the given unique identifier from the index.
        /// @param index The index that should be removed
        /// @param id The unique identifier of the data element to remove.
        function remove(Index storage index, bytes32 id) public {
            Node storage replacementNode;
            Node storage parent;
            Node storage child;
            bytes32 rebalanceOrigin;

            Node storage nodeToDelete = index.nodes[id];

            if (nodeToDelete.id != id) {
                // The id does not exist in the tree.
                return;
            }

            if (nodeToDelete.left != 0x0 || nodeToDelete.right != 0x0) {
                // This node is not a leaf node and thus must replace itself in
                // it's tree by either the previous or next node.
                if (nodeToDelete.left != 0x0) {
                    // This node is guaranteed to not have a right child.
                    replacementNode = index.nodes[getPreviousNode(index, nodeToDelete.id)];
                }
                else {
                    // This node is guaranteed to not have a left child.
                    replacementNode = index.nodes[getNextNode(index, nodeToDelete.id)];
                }
                // The replacementNode is guaranteed to have a parent.
                parent = index.nodes[replacementNode.parent];

                // Keep note of the location that our tree rebalancing should
                // start at.
                rebalanceOrigin = replacementNode.id;

                // Join the parent of the replacement node with any subtree of
                // the replacement node.  We can guarantee that the replacement
                // node has at most one subtree because of how getNextNode and
                // getPreviousNode are used.
                if (parent.left == replacementNode.id) {
                    parent.left = replacementNode.right;
                    if (replacementNode.right != 0x0) {
                        child = index.nodes[replacementNode.right];
                        child.parent = parent.id;
                    }
                }
                if (parent.right == replacementNode.id) {
                    parent.right = replacementNode.left;
                    if (replacementNode.left != 0x0) {
                        child = index.nodes[replacementNode.left];
                        child.parent = parent.id;
                    }
                }

                // Now we replace the nodeToDelete with the replacementNode.
                // This includes parent/child relationships for all of the
                // parent, the left child, and the right child.
                replacementNode.parent = nodeToDelete.parent;
                if (nodeToDelete.parent != 0x0) {
                    parent = index.nodes[nodeToDelete.parent];
                    if (parent.left == nodeToDelete.id) {
                        parent.left = replacementNode.id;
                    }
                    if (parent.right == nodeToDelete.id) {
                        parent.right = replacementNode.id;
                    }
                }
                else {
                    // If the node we are deleting is the root node update the
                    // index root node pointer.
                    index.root = replacementNode.id;
                }

                replacementNode.left = nodeToDelete.left;
                if (nodeToDelete.left != 0x0) {
                    child = index.nodes[nodeToDelete.left];
                    child.parent = replacementNode.id;
                }

                replacementNode.right = nodeToDelete.right;
                if (nodeToDelete.right != 0x0) {
                    child = index.nodes[nodeToDelete.right];
                    child.parent = replacementNode.id;
                }
            }
            else if (nodeToDelete.parent != 0x0) {
                // The node being deleted is a leaf node so we only erase it's
                // parent linkage.
                parent = index.nodes[nodeToDelete.parent];

                if (parent.left == nodeToDelete.id) {
                    parent.left = 0x0;
                }
                if (parent.right == nodeToDelete.id) {
                    parent.right = 0x0;
                }

                // keep note of where the rebalancing should begin.
                rebalanceOrigin = parent.id;
            }
            else {
                // This is both a leaf node and the root node, so we need to
                // unset the root node pointer.
                index.root = 0x0;
            }

            // Now we zero out all of the fields on the nodeToDelete.
            nodeToDelete.id = 0x0;
            nodeToDelete.value = 0;
            nodeToDelete.parent = 0x0;
            nodeToDelete.left = 0x0;
            nodeToDelete.right = 0x0;

            // Walk back up the tree rebalancing
            if (rebalanceOrigin != 0x0) {
                _rebalanceTree(index, rebalanceOrigin);
            }
        }

        bytes2 constant GT = ">";
        bytes2 constant LT = "<";
        bytes2 constant GTE = ">=";
        bytes2 constant LTE = "<=";
        bytes2 constant EQ = "==";

        function _compare(int left, bytes2 operator, int right) internal returns (bool) {
            if (operator == GT) {
                return (left > right);
            }
            if (operator == LT) {
                return (left < right);
            }
            if (operator == GTE) {
                return (left >= right);
            }
            if (operator == LTE) {
                return (left <= right);
            }
            if (operator == EQ) {
                return (left == right);
            }

            // Invalid operator.
            throw;
        }

        function _getMaximum(Index storage index, bytes32 id) internal returns (int) {
                Node storage currentNode = index.nodes[id];

                while (true) {
                    if (currentNode.right == 0x0) {
                        return currentNode.value;
                    }
                    currentNode = index.nodes[currentNode.right];
                }
        }

        function _getMinimum(Index storage index, bytes32 id) internal returns (int) {
                Node storage currentNode = index.nodes[id];

                while (true) {
                    if (currentNode.left == 0x0) {
                        return currentNode.value;
                    }
                    currentNode = index.nodes[currentNode.left];
                }
        }


        /** @dev Query the index for the edge-most node that satisfies the
         *  given query.  For >, >=, and ==, this will be the left-most node
         *  that satisfies the comparison.  For < and <= this will be the
         *  right-most node that satisfies the comparison.
         */
        /// @param index The index that should be queried
        /** @param operator One of '>', '>=', '<', '<=', '==' to specify what
         *  type of comparison operator should be used.
         */
        function query(Index storage index, bytes2 operator, int value) public returns (bytes32) {
                bytes32 rootNodeId = index.root;
                
                if (rootNodeId == 0x0) {
                    // Empty tree.
                    return 0x0;
                }

                Node storage currentNode = index.nodes[rootNodeId];

                while (true) {
                    if (_compare(currentNode.value, operator, value)) {
                        // We have found a match but it might not be the
                        // *correct* match.
                        if ((operator == LT) || (operator == LTE)) {
                            // Need to keep traversing right until this is no
                            // longer true.
                            if (currentNode.right == 0x0) {
                                return currentNode.id;
                            }
                            if (_compare(_getMinimum(index, currentNode.right), operator, value)) {
                                // There are still nodes to the right that
                                // match.
                                currentNode = index.nodes[currentNode.right];
                                continue;
                            }
                            return currentNode.id;
                        }

                        if ((operator == GT) || (operator == GTE) || (operator == EQ)) {
                            // Need to keep traversing left until this is no
                            // longer true.
                            if (currentNode.left == 0x0) {
                                return currentNode.id;
                            }
                            if (_compare(_getMaximum(index, currentNode.left), operator, value)) {
                                currentNode = index.nodes[currentNode.left];
                                continue;
                            }
                            return currentNode.id;
                        }
                    }

                    if ((operator == LT) || (operator == LTE)) {
                        if (currentNode.left == 0x0) {
                            // There are no nodes that are less than the value
                            // so return null.
                            return 0x0;
                        }
                        currentNode = index.nodes[currentNode.left];
                        continue;
                    }

                    if ((operator == GT) || (operator == GTE)) {
                        if (currentNode.right == 0x0) {
                            // There are no nodes that are greater than the value
                            // so return null.
                            return 0x0;
                        }
                        currentNode = index.nodes[currentNode.right];
                        continue;
                    }

                    if (operator == EQ) {
                        if (currentNode.value < value) {
                            if (currentNode.right == 0x0) {
                                return 0x0;
                            }
                            currentNode = index.nodes[currentNode.right];
                            continue;
                        }

                        if (currentNode.value > value) {
                            if (currentNode.left == 0x0) {
                                return 0x0;
                            }
                            currentNode = index.nodes[currentNode.left];
                            continue;
                        }
                    }
                }
        }

        function _rebalanceTree(Index storage index, bytes32 id) internal {
            // Trace back up rebalancing the tree and updating heights as
            // needed..
            Node storage currentNode = index.nodes[id];

            while (true) {
                int balanceFactor = _getBalanceFactor(index, currentNode.id);

                if (balanceFactor == 2) {
                    // Right rotation (tree is heavy on the left)
                    if (_getBalanceFactor(index, currentNode.left) == -1) {
                        // The subtree is leaning right so it need to be
                        // rotated left before the current node is rotated
                        // right.
                        _rotateLeft(index, currentNode.left);
                    }
                    _rotateRight(index, currentNode.id);
                }

                if (balanceFactor == -2) {
                    // Left rotation (tree is heavy on the right)
                    if (_getBalanceFactor(index, currentNode.right) == 1) {
                        // The subtree is leaning left so it need to be
                        // rotated right before the current node is rotated
                        // left.
                        _rotateRight(index, currentNode.right);
                    }
                    _rotateLeft(index, currentNode.id);
                }

                if ((-1 <= balanceFactor) && (balanceFactor <= 1)) {
                    _updateNodeHeight(index, currentNode.id);
                }

                if (currentNode.parent == 0x0) {
                    // Reached the root which may be new due to tree
                    // rotation, so set it as the root and then break.
                    break;
                }

                currentNode = index.nodes[currentNode.parent];
            }
        }

        function _getBalanceFactor(Index storage index, bytes32 id) internal returns (int) {
                Node storage node = index.nodes[id];

                return int(index.nodes[node.left].height) - int(index.nodes[node.right].height);
        }

        function _updateNodeHeight(Index storage index, bytes32 id) internal {
                Node storage node = index.nodes[id];

                node.height = max(index.nodes[node.left].height, index.nodes[node.right].height) + 1;
        }

        function _rotateLeft(Index storage index, bytes32 id) internal {
            Node storage originalRoot = index.nodes[id];

            if (originalRoot.right == 0x0) {
                // Cannot rotate left if there is no right originalRoot to rotate into
                // place.
                throw;
            }

            // The right child is the new root, so it gets the original
            // `originalRoot.parent` as it's parent.
            Node storage newRoot = index.nodes[originalRoot.right];
            newRoot.parent = originalRoot.parent;

            // The original root needs to have it's right child nulled out.
            originalRoot.right = 0x0;

            if (originalRoot.parent != 0x0) {
                // If there is a parent node, it needs to now point downward at
                // the newRoot which is rotating into the place where `node` was.
                Node storage parent = index.nodes[originalRoot.parent];

                // figure out if we're a left or right child and have the
                // parent point to the new node.
                if (parent.left == originalRoot.id) {
                    parent.left = newRoot.id;
                }
                if (parent.right == originalRoot.id) {
                    parent.right = newRoot.id;
                }
            }


            if (newRoot.left != 0) {
                // If the new root had a left child, that moves to be the
                // new right child of the original root node
                Node storage leftChild = index.nodes[newRoot.left];
                originalRoot.right = leftChild.id;
                leftChild.parent = originalRoot.id;
            }

            // Update the newRoot's left node to point at the original node.
            originalRoot.parent = newRoot.id;
            newRoot.left = originalRoot.id;

            if (newRoot.parent == 0x0) {
                index.root = newRoot.id;
            }

            // TODO: are both of these updates necessary?
            _updateNodeHeight(index, originalRoot.id);
            _updateNodeHeight(index, newRoot.id);
        }

        function _rotateRight(Index storage index, bytes32 id) internal {
            Node storage originalRoot = index.nodes[id];

            if (originalRoot.left == 0x0) {
                // Cannot rotate right if there is no left node to rotate into
                // place.
                throw;
            }

            // The left child is taking the place of node, so we update it's
            // parent to be the original parent of the node.
            Node storage newRoot = index.nodes[originalRoot.left];
            newRoot.parent = originalRoot.parent;

            // Null out the originalRoot.left
            originalRoot.left = 0x0;

            if (originalRoot.parent != 0x0) {
                // If the node has a parent, update the correct child to point
                // at the newRoot now.
                Node storage parent = index.nodes[originalRoot.parent];

                if (parent.left == originalRoot.id) {
                    parent.left = newRoot.id;
                }
                if (parent.right == originalRoot.id) {
                    parent.right = newRoot.id;
                }
            }

            if (newRoot.right != 0x0) {
                Node storage rightChild = index.nodes[newRoot.right];
                originalRoot.left = newRoot.right;
                rightChild.parent = originalRoot.id;
            }

            // Update the new root's right node to point to the original node.
            originalRoot.parent = newRoot.id;
            newRoot.right = originalRoot.id;

            if (newRoot.parent == 0x0) {
                index.root = newRoot.id;
            }

            // Recompute heights.
            _updateNodeHeight(index, originalRoot.id);
            _updateNodeHeight(index, newRoot.id);
        }
}


// Resource Pool v0.1.0 (has been modified from the main released version of this library)


// @title ResourcePoolLib - Library for a set of resources that are ready for use.
// @author Piper Merriam 
library ResourcePoolLib {
        /*
         *  Address: 0xd6bbd16eaa6ea3f71a458bffc64c0ca24fc8c58e
         */
        struct Pool {
                uint rotationDelay;
                uint overlapSize;
                uint freezePeriod;

                uint _id;

                GroveLib.Index generationStart;
                GroveLib.Index generationEnd;

                mapping (uint => Generation) generations;
                mapping (address => uint) bonds;
        }

        /*
         * Generations have the following properties.
         *
         * 1. Must always overlap by a minimum amount specified by MIN_OVERLAP.
         *
         *    1   2   3   4   5   6   7   8   9   10  11  12  13
         *    [1:-----------------]
         *                [4:--------------------->
         */
        struct Generation {
                uint id;
                uint startAt;
                uint endAt;
                address[] members;
        }

        /// @dev Creates the next generation for the given pool.  All members from the current generation are carried over (with their order randomized).  The current generation will have it's endAt block set.
        /// @param self The pool to operate on.
        function createNextGeneration(Pool storage self) public returns (uint) {
                /*
                 *  Creat a new pool generation with all of the current
                 *  generation's members copied over in random order.
                 */
                Generation storage previousGeneration = self.generations[self._id];

                self._id += 1;
                Generation storage nextGeneration = self.generations[self._id];
                nextGeneration.id = self._id;
                nextGeneration.startAt = block.number + self.freezePeriod + self.rotationDelay;
                GroveLib.insert(self.generationStart, StringLib.uintToBytes(nextGeneration.id), int(nextGeneration.startAt));

                if (previousGeneration.id == 0) {
                        // This is the first generation so we just need to set
                        // it's `id` and `startAt`.
                        return nextGeneration.id;
                }

                // Set the end date for the current generation.
                previousGeneration.endAt = block.number + self.freezePeriod + self.rotationDelay + self.overlapSize;
                GroveLib.insert(self.generationEnd, StringLib.uintToBytes(previousGeneration.id), int(previousGeneration.endAt));

                // Now we copy the members of the previous generation over to
                // the next generation as well as randomizing their order.
                address[] memory members = previousGeneration.members;

                for (uint i = 0; i < members.length; i++) {
                    // Pick a *random* index and push it onto the next
                    // generation's members.
                    uint index = uint(sha3(block.blockhash(block.number))) % (members.length - nextGeneration.members.length);
                    nextGeneration.members.length += 1;
                    nextGeneration.members[nextGeneration.members.length - 1] = members[index];

                    // Then move the member at the last index into the picked
                    // index's location.
                    members[index] = members[members.length - 1];
                }

                return nextGeneration.id;
        }

        /// @dev Returns the first generation id that fully contains the block window provided.
        /// @param self The pool to operate on.
        /// @param leftBound The left bound for the block window (inclusive)
        /// @param rightBound The right bound for the block window (inclusive)
        function getGenerationForWindow(Pool storage self, uint leftBound, uint rightBound) constant returns (uint) {
            // TODO: tests
                var left = GroveLib.query(self.generationStart, "<=", int(leftBound));

                if (left != 0x0) {
                    Generation memory leftCandidate = self.generations[StringLib.bytesToUInt(left)];
                    if (leftCandidate.startAt <= leftBound && (leftCandidate.endAt >= rightBound || leftCandidate.endAt == 0)) {
                        return leftCandidate.id;
                    }
                }

                var right = GroveLib.query(self.generationEnd, ">=", int(rightBound));
                if (right != 0x0) {
                    Generation memory rightCandidate = self.generations[StringLib.bytesToUInt(right)];
                    if (rightCandidate.startAt <= leftBound && (rightCandidate.endAt >= rightBound || rightCandidate.endAt == 0)) {
                        return rightCandidate.id;
                    }
                }

                return 0;
        }

        /// @dev Returns the first generation in the future that has not yet started.
        /// @param self The pool to operate on.
        function getNextGenerationId(Pool storage self) constant returns (uint) {
            // TODO: tests
                var next = GroveLib.query(self.generationStart, ">", int(block.number));
                if (next == 0x0) {
                    return 0;
                }
                return StringLib.bytesToUInt(next);
        }

        /// @dev Returns the first generation that is currently active.
        /// @param self The pool to operate on.
        function getCurrentGenerationId(Pool storage self) constant returns (uint) {
            // TODO: tests
                var next = GroveLib.query(self.generationEnd, ">", int(block.number));
                if (next != 0x0) {
                    return StringLib.bytesToUInt(next);
                }

                next = GroveLib.query(self.generationStart, "<=", int(block.number));
                if (next != 0x0) {
                    return StringLib.bytesToUInt(next);
                }
                return 0;
        }

        /*
         *  Pool membership API
         */
        /// @dev Returns a boolean for whether the given address is in the given generation.
        /// @param self The pool to operate on.
        /// @param resourceAddress The address to check membership of
        /// @param generationId The id of the generation to check.
        function isInGeneration(Pool storage self, address resourceAddress, uint generationId) constant returns (bool) {
            // TODO: tests
            if (generationId == 0) {
                return false;
            }
            Generation memory generation = self.generations[generationId];
            for (uint i = 0; i < generation.members.length; i++) {
                if (generation.members[i] == resourceAddress) {
                    return true;
                }
            }
            return false;
        }

        /// @dev Returns a boolean for whether the given address is in the current generation.
        /// @param self The pool to operate on.
        /// @param resourceAddress The address to check membership of
        function isInCurrentGeneration(Pool storage self, address resourceAddress) constant returns (bool) {
            // TODO: tests
            return isInGeneration(self, resourceAddress, getCurrentGenerationId(self));
        }

        /// @dev Returns a boolean for whether the given address is in the next queued generation.
        /// @param self The pool to operate on.
        /// @param resourceAddress The address to check membership of
        function isInNextGeneration(Pool storage self, address resourceAddress) constant returns (bool) {
            // TODO: tests
            return isInGeneration(self, resourceAddress, getNextGenerationId(self));
        }

        /// @dev Returns a boolean for whether the given address is in either the current generation or the next queued generation.
        /// @param self The pool to operate on.
        /// @param resourceAddress The address to check membership of
        function isInPool(Pool storage self, address resourceAddress) constant returns (bool) {
            // TODO: tests
            return (isInCurrentGeneration(self, resourceAddress) || isInNextGeneration(self, resourceAddress));
        }

        event _AddedToGeneration(address indexed resourceAddress, uint indexed generationId);
        /// @dev Function to expose the _AddedToGeneration event to contracts.
        /// @param resourceAddress The address that was added
        /// @param generationId The id of the generation.
        function AddedToGeneration(address resourceAddress, uint generationId) public {
                _AddedToGeneration(resourceAddress, generationId);
        }

        event _RemovedFromGeneration(address indexed resourceAddress, uint indexed generationId);
        /// @dev Function to expose the _AddedToGeneration event to contracts.
        /// @param resourceAddress The address that was removed.
        /// @param generationId The id of the generation.
        function RemovedFromGeneration(address resourceAddress, uint generationId) public {
                _RemovedFromGeneration(resourceAddress, generationId);
        }

        /// @dev Returns a boolean as to whether the provided address is allowed to enter the pool at this time.
        /// @param self The pool to operate on.
        /// @param resourceAddress The address in question
        /// @param minimumBond The minimum bond amount that should be required for entry.
        function canEnterPool(Pool storage self, address resourceAddress, uint minimumBond) constant returns (bool) {
            /*
             *  - bond
             *  - pool is open
             *  - not already in it.
             *  - not already left it.
             */
            // TODO: tests
            if (self.bonds[resourceAddress] < minimumBond) {
                // Insufficient bond balance;
                return false;
            }

            if (isInPool(self, resourceAddress)) {
                // Already in the pool either in the next upcoming generation
                // or the currently active generation.
                return false;
            }

            var nextGenerationId = getNextGenerationId(self);
            if (nextGenerationId != 0) {
                var nextGeneration = self.generations[nextGenerationId];
                if (block.number + self.freezePeriod >= nextGeneration.startAt) {
                    // Next generation starts too soon.
                    return false;
                }
            }

            return true;
        }

        /// @dev Adds the address to pool by adding them to the next generation (as well as creating it if it doesn't exist).
        /// @param self The pool to operate on.
        /// @param resourceAddress The address to be added to the pool
        /// @param minimumBond The minimum bond amount that should be required for entry.
        function enterPool(Pool storage self, address resourceAddress, uint minimumBond) public returns (uint) {
            if (!canEnterPool(self, resourceAddress, minimumBond)) {
                throw;
            }
            uint nextGenerationId = getNextGenerationId(self);
            if (nextGenerationId == 0) {
                // No next generation has formed yet so create it.
                nextGenerationId = createNextGeneration(self);
            }
            Generation storage nextGeneration = self.generations[nextGenerationId];
            // now add the new address.
            nextGeneration.members.length += 1;
            nextGeneration.members[nextGeneration.members.length - 1] = resourceAddress;
            return nextGenerationId;
        }

        /// @dev Returns a boolean as to whether the provided address is allowed to exit the pool at this time.
        /// @param self The pool to operate on.
        /// @param resourceAddress The address in question
        function canExitPool(Pool storage self, address resourceAddress) constant returns (bool) {
            if (!isInCurrentGeneration(self, resourceAddress)) {
                // Not in the pool.
                return false;
            }

            uint nextGenerationId = getNextGenerationId(self);
            if (nextGenerationId == 0) {
                // Next generation hasn't been generated yet.
                return true;
            }

            if (self.generations[nextGenerationId].startAt - self.freezePeriod <= block.number) {
                // Next generation starts too soon.
                return false;
            }

            // They can leave if they are still in the next generation.
            // otherwise they have already left it.
            return isInNextGeneration(self, resourceAddress);
        }


        /// @dev Removes the address from the pool by removing them from the next generation (as well as creating it if it doesn't exist)
        /// @param self The pool to operate on.
        /// @param resourceAddress The address in question
        function exitPool(Pool storage self, address resourceAddress) public returns (uint) {
            if (!canExitPool(self, resourceAddress)) {
                throw;
            }
            uint nextGenerationId = getNextGenerationId(self);
            if (nextGenerationId == 0) {
                // No next generation has formed yet so create it.
                nextGenerationId = createNextGeneration(self);
            }
            // Remove them from the generation
            removeFromGeneration(self, nextGenerationId, resourceAddress);
            return nextGenerationId;
        }

        /// @dev Removes the address from a generation's members array. Returns boolean as to whether removal was successful.
        /// @param self The pool to operate on.
        /// @param generationId The id of the generation to operate on.
        /// @param resourceAddress The address to be removed.
        function removeFromGeneration(Pool storage self, uint generationId, address resourceAddress) public returns (bool){
            Generation storage generation = self.generations[generationId];
            // now remove the address
            for (uint i = 0; i < generation.members.length; i++) {
                if (generation.members[i] == resourceAddress) {
                    generation.members[i] = generation.members[generation.members.length - 1];
                    generation.members.length -= 1;
                    return true;
                }
            }
            return false;
        }

        /*
         *  Bonding
         */

        /// @dev Subtracts the amount from an account's bond balance.
        /// @param self The pool to operate on.
        /// @param resourceAddress The address of the account
        /// @param value The value to subtract.
        function deductFromBond(Pool storage self, address resourceAddress, uint value) public {
                /*
                 *  deduct funds from a bond value without risk of an
                 *  underflow.
                 */
                if (value > self.bonds[resourceAddress]) {
                        // Prevent Underflow.
                        throw;
                }
                self.bonds[resourceAddress] -= value;
        }

        /// @dev Adds the amount to an account's bond balance.
        /// @param self The pool to operate on.
        /// @param resourceAddress The address of the account
        /// @param value The value to add.
        function addToBond(Pool storage self, address resourceAddress, uint value) public {
                /*
                 *  Add funds to a bond value without risk of an
                 *  overflow.
                 */
                if (self.bonds[resourceAddress] + value < self.bonds[resourceAddress]) {
                        // Prevent Overflow
                        throw;
                }
                self.bonds[resourceAddress] += value;
        }

        /// @dev Withdraws a bond amount from an address's bond account, sending them the corresponding amount in ether.
        /// @param self The pool to operate on.
        /// @param resourceAddress The address of the account
        /// @param value The value to withdraw.
        function withdrawBond(Pool storage self, address resourceAddress, uint value, uint minimumBond) public {
                /*
                 *  Only if you are not in either of the current call pools.
                 */
                // Prevent underflow
                if (value > self.bonds[resourceAddress]) {
                        throw;
                }

                // Do a permissions check to be sure they can withdraw the
                // funds.
                if (isInPool(self, resourceAddress)) {
                        if (self.bonds[resourceAddress] - value < minimumBond) {
                            return;
                        }
                }

                deductFromBond(self, resourceAddress, value);
                if (!resourceAddress.send(value)) {
                        // Potentially sending money to a contract that
                        // has a fallback function.  So instead, try
                        // tranferring the funds with the call api.
                        if (!resourceAddress.call.gas(msg.gas).value(value)()) {
                                // Revert the entire transaction.  No
                                // need to destroy the funds.
                                throw;
                        }
                }
        }
}


contract Relay {
        address operator;

        function Relay() {
                operator = msg.sender;
        }

        function relayCall(address contractAddress, bytes4 abiSignature, bytes data) public returns (bool) {
                if (msg.sender != operator) {
                        throw;
                }
                return contractAddress.call(abiSignature, data);
        }
}




library ScheduledCallLib {
    /*
     *  Address: 0x5c3623dcef2d5168dbe3e8cc538788cd8912d898
     */
    struct CallDatabase {
        Relay unauthorizedRelay;
        Relay authorizedRelay;

        bytes32 lastCallKey;
        bytes lastData;
        uint lastDataLength;
        bytes32 lastDataHash;

        ResourcePoolLib.Pool callerPool;
        GroveLib.Index callIndex;

        AccountingLib.Bank gasBank;

        mapping (bytes32 => Call) calls;
        mapping (bytes32 => bytes) data_registry;

        mapping (bytes32 => bool) accountAuthorizations;
    }

    struct Call {
            address contractAddress;
            address scheduledBy;
            uint calledAtBlock;
            uint targetBlock;
            uint8 gracePeriod;
            uint nonce;
            uint baseGasPrice;
            uint gasPrice;
            uint gasUsed;
            uint gasCost;
            uint payout;
            uint fee;
            address executedBy;
            bytes4 abiSignature;
            bool isCancelled;
            bool wasCalled;
            bool wasSuccessful;
            bytes32 dataHash;
    }

    // The author (Piper Merriam) address.
    address constant owner = 0xd3cda913deb6f67967b99d67acdfa1712c293601;

    /*
     *  Getter methods for `Call` information
     */
    function getCallContractAddress(CallDatabase storage self, bytes32 callKey) constant returns (address) {
            return self.calls[callKey].contractAddress;
    }

    function getCallScheduledBy(CallDatabase storage self, bytes32 callKey) constant returns (address) {
            return self.calls[callKey].scheduledBy;
    }

    function getCallCalledAtBlock(CallDatabase storage self, bytes32 callKey) constant returns (uint) {
            return self.calls[callKey].calledAtBlock;
    }

    function getCallGracePeriod(CallDatabase storage self, bytes32 callKey) constant returns (uint) {
            return self.calls[callKey].gracePeriod;
    }

    function getCallTargetBlock(CallDatabase storage self, bytes32 callKey) constant returns (uint) {
            return self.calls[callKey].targetBlock;
    }

    function getCallBaseGasPrice(CallDatabase storage self, bytes32 callKey) constant returns (uint) {
            return self.calls[callKey].baseGasPrice;
    }

    function getCallGasPrice(CallDatabase storage self, bytes32 callKey) constant returns (uint) {
            return self.calls[callKey].gasPrice;
    }

    function getCallGasUsed(CallDatabase storage self, bytes32 callKey) constant returns (uint) {
            return self.calls[callKey].gasUsed;
    }

    function getCallABISignature(CallDatabase storage self, bytes32 callKey) constant returns (bytes4) {
            return self.calls[callKey].abiSignature;
    }

    function checkIfCalled(CallDatabase storage self, bytes32 callKey) constant returns (bool) {
            return self.calls[callKey].wasCalled;
    }

    function checkIfSuccess(CallDatabase storage self, bytes32 callKey) constant returns (bool) {
            return self.calls[callKey].wasSuccessful;
    }

    function checkIfCancelled(CallDatabase storage self, bytes32 callKey) constant returns (bool) {
            return self.calls[callKey].isCancelled;
    }

    function getCallDataHash(CallDatabase storage self, bytes32 callKey) constant returns (bytes32) {
            return self.calls[callKey].dataHash;
    }

    function getCallPayout(CallDatabase storage self, bytes32 callKey) constant returns (uint) {
            return self.calls[callKey].payout;
    }

    function getCallFee(CallDatabase storage self, bytes32 callKey) constant returns (uint) {
            return self.calls[callKey].fee;
    }

    /*
     *  Scheduling Authorization API
     */

    function addAuthorization(CallDatabase storage self, address schedulerAddress, address contractAddress) public {
            self.accountAuthorizations[sha3(schedulerAddress, contractAddress)] = true;
    }

    function removeAuthorization(CallDatabase storage self, address schedulerAddress, address contractAddress) public {
            self.accountAuthorizations[sha3(schedulerAddress, contractAddress)] = false;
    }

    function checkAuthorization(CallDatabase storage self, address schedulerAddress, address contractAddress) constant returns (bool) {
            return self.accountAuthorizations[sha3(schedulerAddress, contractAddress)];
    }

    /*
     *  Data Registry API
     */
    function getCallData(CallDatabase storage self, bytes32 callKey) constant returns (bytes) {
            return self.data_registry[self.calls[callKey].dataHash];
    }

    /*
     *  API used by Alarm service
     */
    // The number of blocks that each caller in the pool has to complete their
    // call.
    uint constant CALL_WINDOW_SIZE = 16;

    function getGenerationIdForCall(CallDatabase storage self, bytes32 callKey) constant returns (uint) {
            Call call = self.calls[callKey];
            return ResourcePoolLib.getGenerationForWindow(self.callerPool, call.targetBlock, call.targetBlock + call.gracePeriod);
    }

    function getDesignatedCaller(CallDatabase storage self, bytes32 callKey, uint blockNumber) constant returns (address) {
            /*
             *  Returns the caller from the current call pool who is
             *  designated as the executor of this call.
             */
            Call call = self.calls[callKey];
            if (blockNumber < call.targetBlock || blockNumber > call.targetBlock + call.gracePeriod) {
                    // blockNumber not within call window.
                    return 0x0;
            }

            // Check if we are in free-for-all window.
            uint numWindows = call.gracePeriod / CALL_WINDOW_SIZE;
            uint blockWindow = (blockNumber - call.targetBlock) / CALL_WINDOW_SIZE;

            if (blockWindow + 2 > numWindows) {
                    // We are within the free-for-all period.
                    return 0x0;
            }

            // Lookup the pool that full contains the call window for this
            // call.
            uint generationId = ResourcePoolLib.getGenerationForWindow(self.callerPool, call.targetBlock, call.targetBlock + call.gracePeriod);
            if (generationId == 0) {
                    // No pool currently in operation.
                    return 0x0;
            }
            var generation = self.callerPool.generations[generationId];

            uint offset = uint(callKey) % generation.members.length;
            return generation.members[(offset + blockWindow) % generation.members.length];
    }

    event _AwardedMissedBlockBonus(address indexed fromCaller, address indexed toCaller, uint indexed generationId, bytes32 callKey, uint blockNumber, uint bonusAmount);
    function AwardedMissedBlockBonus(address fromCaller, address toCaller, uint generationId, bytes32 callKey, uint blockNumber, uint bonusAmount) public {
        _AwardedMissedBlockBonus(fromCaller, toCaller, generationId, callKey, blockNumber, bonusAmount);
    }

    function getMinimumBond() constant returns (uint) {
            return tx.gasprice * block.gaslimit;
    }

    function doBondBonusTransfer(CallDatabase storage self, address fromCaller, address toCaller) internal returns (uint) {
            uint bonusAmount = getMinimumBond();
            uint bondBalance = self.callerPool.bonds[fromCaller];

            // If the bond balance is lower than the award
            // balance, then adjust the reward amount to
            // match the bond balance.
            if (bonusAmount > bondBalance) {
                    bonusAmount = bondBalance;
            }

            // Transfer the funds fromCaller => toCaller
            ResourcePoolLib.deductFromBond(self.callerPool, fromCaller, bonusAmount);
            ResourcePoolLib.addToBond(self.callerPool, toCaller, bonusAmount);

            return bonusAmount;
    }

    function awardMissedBlockBonus(CallDatabase storage self, address toCaller, bytes32 callKey) public {
            var call = self.calls[callKey];

            var generation = self.callerPool.generations[ResourcePoolLib.getGenerationForWindow(self.callerPool, call.targetBlock, call.targetBlock + call.gracePeriod)];
            uint i;
            uint bonusAmount;
            address fromCaller;

            uint numWindows = call.gracePeriod / CALL_WINDOW_SIZE;
            uint blockWindow = (block.number - call.targetBlock) / CALL_WINDOW_SIZE;

            // Check if we are within the free-for-all period.  If so, we
            // award from all pool members.
            if (blockWindow + 2 > numWindows) {
                    address firstCaller = getDesignatedCaller(self, callKey, call.targetBlock);
                    for (i = call.targetBlock; i <= call.targetBlock + call.gracePeriod; i += CALL_WINDOW_SIZE) {
                            fromCaller = getDesignatedCaller(self, callKey, i);
                            if (fromCaller == firstCaller && i != call.targetBlock) {
                                    // We have already gone through all of
                                    // the pool callers so we should break
                                    // out of the loop.
                                    break;
                            }
                            if (fromCaller == toCaller) {
                                    continue;
                            }
                            bonusAmount = doBondBonusTransfer(self, fromCaller, toCaller);

                            // Log the bonus was awarded.
                            AwardedMissedBlockBonus(fromCaller, toCaller, generation.id, callKey, block.number, bonusAmount);
                    }
                    return;
            }

            // Special case for single member and empty pools
            if (generation.members.length < 2) {
                    return;
            }

            // Otherwise the award comes from the previous caller.
            for (i = 0; i < generation.members.length; i++) {
                    // Find where the member is in the pool and
                    // award from the previous pool members bond.
                    if (generation.members[i] == toCaller) {
                            fromCaller = generation.members[(i + generation.members.length - 1) % generation.members.length];

                            bonusAmount = doBondBonusTransfer(self, fromCaller, toCaller);

                            // Log the bonus was awarded.
                            AwardedMissedBlockBonus(fromCaller, toCaller, generation.id, callKey, block.number, bonusAmount);

                            // Remove the caller from the next pool.
                            if (ResourcePoolLib.getNextGenerationId(self.callerPool) == 0) {
                                    // This is the first address to modify the
                                    // current pool so we need to setup the next
                                    // pool.
                                    ResourcePoolLib.createNextGeneration(self.callerPool);
                            }
                            ResourcePoolLib.removeFromGeneration(self.callerPool, ResourcePoolLib.getNextGenerationId(self.callerPool), fromCaller);
                            return;
                    }
            }
    }

    /*
     *  Data registration API
     */
    event _DataRegistered(bytes32 indexed dataHash);
    function DataRegistered(bytes32 dataHash) constant {
        _DataRegistered(dataHash);
    }

    function registerData(CallDatabase storage self, bytes data) public {
            self.lastData.length = data.length - 4;
            if (data.length > 4) {
                    for (uint i = 0; i < self.lastData.length; i++) {
                            self.lastData[i] = data[i + 4];
                    }
            }
            self.data_registry[sha3(self.lastData)] = self.lastData;
            self.lastDataHash = sha3(self.lastData);
            self.lastDataLength = self.lastData.length;
    }

    /*
     *  Call execution API
     */
    // This number represents the constant gas cost of the addition
    // operations that occur in `doCall` that cannot be tracked with
    // msg.gas.
    uint constant EXTRA_CALL_GAS = 153321;

    // This number represents the overall overhead involved in executing a
    // scheduled call.
    uint constant CALL_OVERHEAD = 120104;

    event _CallExecuted(address indexed executedBy, bytes32 indexed callKey);
    function CallExecuted(address executedBy, bytes32 callKey) public {
        _CallExecuted(executedBy, callKey);
    }
    event _CallAborted(address indexed executedBy, bytes32 indexed callKey, bytes18 reason);
    function CallAborted(address executedBy, bytes32 callKey, bytes18 reason) public {
        _CallAborted(executedBy, callKey, reason);
    }

    function doCall(CallDatabase storage self, bytes32 callKey, address msgSender) public {
            uint gasBefore = msg.gas;

            Call storage call = self.calls[callKey];

            if (call.wasCalled) {
                    // The call has already been executed so don't do it again.
                    _CallAborted(msg.sender, callKey, "ALREADY CALLED");
                    return;
            }

            if (call.isCancelled) {
                    // The call was cancelled so don't execute it.
                    _CallAborted(msg.sender, callKey, "CANCELLED");
                    return;
            }

            if (call.contractAddress == 0x0) {
                    // This call key doesnt map to a registered call.
                    _CallAborted(msg.sender, callKey, "UNKNOWN");
                    return;
            }

            if (block.number < call.targetBlock) {
                    // Target block hasnt happened yet.
                    _CallAborted(msg.sender, callKey, "TOO EARLY");
                    return;
            }

            if (block.number > call.targetBlock + call.gracePeriod) {
                    // The blockchain has advanced passed the period where
                    // it was allowed to be called.
                    _CallAborted(msg.sender, callKey, "TOO LATE");
                    return;
            }

            uint heldBalance = getCallMaxCost(self, callKey);

            if (self.gasBank.accountBalances[call.scheduledBy] < heldBalance) {
                    // The scheduledBy's account balance is less than the
                    // current gasLimit and thus potentiall can't pay for
                    // the call.

                    // Mark it as called since it was.
                    call.wasCalled = true;
                    
                    // Log it.
                    _CallAborted(msg.sender, callKey, "INSUFFICIENT_FUNDS");
                    return;
            }

            // Check if this caller is allowed to execute the call.
            if (self.callerPool.generations[ResourcePoolLib.getCurrentGenerationId(self.callerPool)].members.length > 0) {
                    address designatedCaller = getDesignatedCaller(self, callKey, block.number);
                    if (designatedCaller != 0x0 && designatedCaller != msgSender) {
                            // This call was reserved for someone from the
                            // bonded pool of callers and can only be
                            // called by them during this block window.
                            _CallAborted(msg.sender, callKey, "WRONG_CALLER");
                            return;
                    }

                    uint blockWindow = (block.number - call.targetBlock) / CALL_WINDOW_SIZE;
                    if (blockWindow > 0) {
                            // Someone missed their call so this caller
                            // gets to claim their bond for picking up
                            // their slack.
                            awardMissedBlockBonus(self, msgSender, callKey);
                    }
            }

            // Log metadata about the call.
            call.gasPrice = tx.gasprice;
            call.executedBy = msgSender;
            call.calledAtBlock = block.number;

            // Fetch the call data
            var data = self.data_registry[call.dataHash];

            // During the call, we need to put enough funds to pay for the
            // call on hold to ensure they are available to pay the caller.
            AccountingLib.withdraw(self.gasBank, call.scheduledBy, heldBalance);

            // Mark whether the function call was successful.
            if (checkAuthorization(self, call.scheduledBy, call.contractAddress)) {
                    call.wasSuccessful = self.authorizedRelay.relayCall.gas(msg.gas - CALL_OVERHEAD)(call.contractAddress, call.abiSignature, data);
            }
            else {
                    call.wasSuccessful = self.unauthorizedRelay.relayCall.gas(msg.gas - CALL_OVERHEAD)(call.contractAddress, call.abiSignature, data);
            }

            // Add the held funds back into the scheduler's account.
            AccountingLib.deposit(self.gasBank, call.scheduledBy, heldBalance);

            // Mark the call as having been executed.
            call.wasCalled = true;

            // Compute the scalar (0 - 200) for the fee.
            uint feeScalar = getCallFeeScalar(call.baseGasPrice, call.gasPrice);

            // Log how much gas this call used.  EXTRA_CALL_GAS is a fixed
            // amount that represents the gas usage of the commands that
            // happen after this line.
            call.gasUsed = (gasBefore - msg.gas + EXTRA_CALL_GAS);
            call.gasCost = call.gasUsed * call.gasPrice;

            // Now we need to pay the caller as well as keep fee.
            // callerPayout -> call cost + 1%
            // fee -> 1% of callerPayout
            call.payout = call.gasCost * feeScalar * 101 / 10000;
            call.fee = call.gasCost * feeScalar / 10000;

            AccountingLib.deductFunds(self.gasBank, call.scheduledBy, call.payout + call.fee);

            AccountingLib.addFunds(self.gasBank, msgSender, call.payout);
            AccountingLib.addFunds(self.gasBank, owner, call.fee);
    }

    function getCallMaxCost(CallDatabase storage self, bytes32 callKey) constant returns (uint) {
            /*
             *  tx.gasprice * block.gaslimit
             *  
             */
            // call cost + 2%
            var call = self.calls[callKey];

            uint gasCost = tx.gasprice * block.gaslimit;
            uint feeScalar = getCallFeeScalar(call.baseGasPrice, tx.gasprice);

            return gasCost * feeScalar * 102 / 10000;
    }

    function getCallFeeScalar(uint baseGasPrice, uint gasPrice) constant returns (uint) {
            /*
             *  Return a number between 0 - 200 to scale the fee based on
             *  the gas price set for the calling transaction as compared
             *  to the gas price of the scheduling transaction.
             *
             *  - number approaches zero as the transaction gas price goes
             *  above the gas price recorded when the call was scheduled.
             *
             *  - the number approaches 200 as the transaction gas price
             *  drops under the price recorded when the call was scheduled.
             *
             *  This encourages lower gas costs as the lower the gas price
             *  for the executing transaction, the higher the payout to the
             *  caller.
             */
            if (gasPrice > baseGasPrice) {
                    return 100 * baseGasPrice / gasPrice;
            }
            else {
                    return 200 - 100 * baseGasPrice / (2 * baseGasPrice - gasPrice);
            }
    }

    /*
     *  Call Scheduling API
     */

    // The result of `sha()` so that we can validate that people aren't
    // looking up call data that failed to register.
    bytes32 constant emptyDataHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    function computeCallKey(address scheduledBy, address contractAddress, bytes4 abiSignature, bytes32 dataHash, uint targetBlock, uint8 gracePeriod, uint nonce) constant returns (bytes32) {
            return sha3(scheduledBy, contractAddress, abiSignature, dataHash, targetBlock, gracePeriod, nonce);
    }

    // Ten minutes into the future.
    uint constant MAX_BLOCKS_IN_FUTURE = 40;

    event _CallScheduled(bytes32 indexed callKey);
    function CallScheduled(bytes32 callKey) public {
        _CallScheduled(callKey);
    }
    event _CallRejected(bytes32 indexed callKey, bytes15 reason);
    function CallRejected(bytes32 callKey, bytes15 reason) public {
        _CallRejected(callKey, reason);
    }

    function getCallWindowSize() public returns (uint) {
        return CALL_WINDOW_SIZE;
    }

    function getMinimumGracePeriod() public returns (uint) {
        return 4 * CALL_WINDOW_SIZE;
    }

    function scheduleCall(CallDatabase storage self, address schedulerAddress, address contractAddress, bytes4 abiSignature, bytes32 dataHash, uint targetBlock, uint8 gracePeriod, uint nonce) public returns (bytes15) {
            /*
             * Primary API for scheduling a call.  Prior to calling this
             * the data should already have been registered through the
             * `registerData` API.
             */
            bytes32 callKey = computeCallKey(schedulerAddress, contractAddress, abiSignature, dataHash, targetBlock, gracePeriod, nonce);

            if (dataHash != emptyDataHash && self.data_registry[dataHash].length == 0) {
                    // Don't allow registering calls if the data hash has
                    // not actually been registered.  The only exception is
                    // the *emptyDataHash*.
                    return "NO_DATA";
            }

            if (targetBlock < block.number + MAX_BLOCKS_IN_FUTURE) {
                    // Don't allow scheduling further than
                    // MAX_BLOCKS_IN_FUTURE
                    return "TOO_SOON";
            }
            Call storage call = self.calls[callKey];

            if (call.contractAddress != 0x0) {
                    return "DUPLICATE";
            }

            if (gracePeriod < getMinimumGracePeriod()) {
                    return "GRACE_TOO_SHORT";
            }

            self.lastCallKey = callKey;

            call.contractAddress = contractAddress;
            call.scheduledBy = schedulerAddress;
            call.nonce = nonce;
            call.abiSignature = abiSignature;
            call.dataHash = dataHash;
            call.targetBlock = targetBlock;
            call.gracePeriod = gracePeriod;
            call.baseGasPrice = tx.gasprice;

            // Put the call into the grove index.
            GroveLib.insert(self.callIndex, callKey, int(call.targetBlock));

            return 0x0;
    }

    event _CallCancelled(bytes32 indexed callKey);
    function CallCancelled(bytes32 callKey) public {
        _CallCancelled(callKey);
    }

    // Two minutes
    uint constant MIN_CANCEL_WINDOW = 8;

    function cancelCall(CallDatabase storage self, bytes32 callKey, address msgSender) public returns (bool) {
            Call storage call = self.calls[callKey];
            if (call.scheduledBy != msgSender) {
                    // Nobody but the scheduler can cancel a call.
                    return false;
            }
            if (call.wasCalled) {
                    // No need to cancel a call that already was executed.
                    return false;
            }
            if (call.targetBlock - MIN_CANCEL_WINDOW <= block.number) {
                    // Call cannot be cancelled this close to execution.
                    return false;
            }
            call.isCancelled = true;
            return true;
    }
}


/*
 *  Ethereum Alarm Service
 *  Version 0.4.0
 *
 *  address: 0x07307d0b136a79bac718f43388aed706389c4588
 */
contract Alarm {
        /*
         *  Constructor
         *
         *  - sets up relays
         *  - configures the caller pool.
         */
        function Alarm() {
                callDatabase.unauthorizedRelay = new Relay();
                callDatabase.authorizedRelay = new Relay();

                callDatabase.callerPool.freezePeriod = 80;
                callDatabase.callerPool.rotationDelay = 80;
                callDatabase.callerPool.overlapSize = 256;
        }

        ScheduledCallLib.CallDatabase callDatabase;

        // The author (Piper Merriam) address.
        address constant owner = 0xd3cda913deb6f67967b99d67acdfa1712c293601;

        /*
         *  Account Management API
         */
        function getAccountBalance(address accountAddress) constant public returns (uint) {
                return callDatabase.gasBank.accountBalances[accountAddress];
        }

        function deposit() public {
                deposit(msg.sender);
        }

        function deposit(address accountAddress) public {
                /*
                 *  Public API for depositing funds in a specified account.
                 */
                AccountingLib.deposit(callDatabase.gasBank, accountAddress, msg.value);
                AccountingLib.Deposit(msg.sender, accountAddress, msg.value);
        }

        function withdraw(uint value) public {
                /*
                 *  Public API for withdrawing funds.
                 */
                if (AccountingLib.withdraw(callDatabase.gasBank, msg.sender, value)) {
                        AccountingLib.Withdrawal(msg.sender, value);
                }
                else {
                        AccountingLib.InsufficientFunds(msg.sender, value, callDatabase.gasBank.accountBalances[msg.sender]);
                }
        }

        function() {
                /*
                 *  Fallback function that allows depositing funds just by
                 *  sending a transaction.
                 */
                deposit(msg.sender);
        }

        /*
         *  Scheduling Authorization API
         */
        function unauthorizedAddress() constant returns (address) {
                return address(callDatabase.unauthorizedRelay);
        }

        function authorizedAddress() constant returns (address) {
                return address(callDatabase.authorizedRelay);
        }

        function addAuthorization(address schedulerAddress) public {
                ScheduledCallLib.addAuthorization(callDatabase, schedulerAddress, msg.sender);
        }

        function removeAuthorization(address schedulerAddress) public {
                callDatabase.accountAuthorizations[sha3(schedulerAddress, msg.sender)] = false;
        }

        function checkAuthorization(address schedulerAddress, address contractAddress) constant returns (bool) {
                return callDatabase.accountAuthorizations[sha3(schedulerAddress, contractAddress)];
        }

        /*
         *  Caller bonding
         */
        function getMinimumBond() constant returns (uint) {
                return ScheduledCallLib.getMinimumBond();
        }

        function depositBond() public {
                ResourcePoolLib.addToBond(callDatabase.callerPool, msg.sender, msg.value);
        }

        function withdrawBond(uint value) public {
                ResourcePoolLib.withdrawBond(callDatabase.callerPool, msg.sender, value, getMinimumBond());
        }

        function getBondBalance() constant returns (uint) {
                return getBondBalance(msg.sender);
        }

        function getBondBalance(address callerAddress) constant returns (uint) {
                return callDatabase.callerPool.bonds[callerAddress];
        }


        /*
         *  Pool Management
         */
        function getGenerationForCall(bytes32 callKey) constant returns (uint) {
                var call = callDatabase.calls[callKey];
                return ResourcePoolLib.getGenerationForWindow(callDatabase.callerPool, call.targetBlock, call.targetBlock + call.gracePeriod);
        }

        function getGenerationSize(uint generationId) constant returns (uint) {
                return callDatabase.callerPool.generations[generationId].members.length;
        }

        function getGenerationStartAt(uint generationId) constant returns (uint) {
                return callDatabase.callerPool.generations[generationId].startAt;
        }

        function getGenerationEndAt(uint generationId) constant returns (uint) {
                return callDatabase.callerPool.generations[generationId].endAt;
        }

        function getCurrentGenerationId() constant returns (uint) {
                return ResourcePoolLib.getCurrentGenerationId(callDatabase.callerPool);
        }

        function getNextGenerationId() constant returns (uint) {
                return ResourcePoolLib.getNextGenerationId(callDatabase.callerPool);
        }

        function isInPool() constant returns (bool) {
                return ResourcePoolLib.isInPool(callDatabase.callerPool, msg.sender);
        }

        function isInPool(address callerAddress) constant returns (bool) {
                return ResourcePoolLib.isInPool(callDatabase.callerPool, callerAddress);
        }

        function isInGeneration(uint generationId) constant returns (bool) {
                return isInGeneration(msg.sender, generationId);
        }

        function isInGeneration(address callerAddress, uint generationId) constant returns (bool) {
                return ResourcePoolLib.isInGeneration(callDatabase.callerPool, callerAddress, generationId);
        }

        /*
         *  Pool Meta information
         */
        function getPoolFreezePeriod() constant returns (uint) {
                return callDatabase.callerPool.freezePeriod;
        }

        function getPoolOverlapSize() constant returns (uint) {
                return callDatabase.callerPool.overlapSize;
        }

        function getPoolRotationDelay() constant returns (uint) {
                return callDatabase.callerPool.rotationDelay;
        }

        /*
         *  Pool Membership
         */
        function canEnterPool() constant returns (bool) {
                return ResourcePoolLib.canEnterPool(callDatabase.callerPool, msg.sender, getMinimumBond());
        }

        function canEnterPool(address callerAddress) constant returns (bool) {
                return ResourcePoolLib.canEnterPool(callDatabase.callerPool, callerAddress, getMinimumBond());
        }

        function canExitPool() constant returns (bool) {
                return ResourcePoolLib.canExitPool(callDatabase.callerPool, msg.sender);
        }

        function canExitPool(address callerAddress) constant returns (bool) {
                return ResourcePoolLib.canExitPool(callDatabase.callerPool, callerAddress);
        }

        function enterPool() public {
                uint generationId = ResourcePoolLib.enterPool(callDatabase.callerPool, msg.sender, getMinimumBond());
                ResourcePoolLib.AddedToGeneration(msg.sender, generationId);
        }

        function exitPool() public {
                uint generationId = ResourcePoolLib.exitPool(callDatabase.callerPool, msg.sender);
                ResourcePoolLib.RemovedFromGeneration(msg.sender, generationId);
        }

        /*
         *  Call Information API
         */

        function getLastCallKey() constant returns (bytes32) {
                return callDatabase.lastCallKey;
        }

        /*
         *  Getter methods for `Call` information
         */
        function getCallContractAddress(bytes32 callKey) constant returns (address) {
                return ScheduledCallLib.getCallContractAddress(callDatabase, callKey);
        }

        function getCallScheduledBy(bytes32 callKey) constant returns (address) {
                return ScheduledCallLib.getCallScheduledBy(callDatabase, callKey);
        }

        function getCallCalledAtBlock(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallCalledAtBlock(callDatabase, callKey);
        }

        function getCallGracePeriod(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallGracePeriod(callDatabase, callKey);
        }

        function getCallTargetBlock(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallTargetBlock(callDatabase, callKey);
        }

        function getCallBaseGasPrice(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallBaseGasPrice(callDatabase, callKey);
        }

        function getCallGasPrice(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallGasPrice(callDatabase, callKey);
        }

        function getCallGasUsed(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallGasUsed(callDatabase, callKey);
        }

        function getCallABISignature(bytes32 callKey) constant returns (bytes4) {
                return ScheduledCallLib.getCallABISignature(callDatabase, callKey);
        }

        function checkIfCalled(bytes32 callKey) constant returns (bool) {
                return ScheduledCallLib.checkIfCalled(callDatabase, callKey);
        }

        function checkIfSuccess(bytes32 callKey) constant returns (bool) {
                return ScheduledCallLib.checkIfSuccess(callDatabase, callKey);
        }

        function checkIfCancelled(bytes32 callKey) constant returns (bool) {
                return ScheduledCallLib.checkIfCancelled(callDatabase, callKey);
        }

        function getCallDataHash(bytes32 callKey) constant returns (bytes32) {
                return ScheduledCallLib.getCallDataHash(callDatabase, callKey);
        }

        function getCallPayout(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallPayout(callDatabase, callKey);
        }

        function getCallFee(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallFee(callDatabase, callKey);
        }

        function getCallMaxCost(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getCallMaxCost(callDatabase, callKey);
        }

        function getCallData(bytes32 callKey) constant returns (bytes) {
                return callDatabase.data_registry[callDatabase.calls[callKey].dataHash];
        }

        /*
         *  Data registration API
         */
        function registerData() public {
                ScheduledCallLib.registerData(callDatabase, msg.data);
                ScheduledCallLib.DataRegistered(callDatabase.lastDataHash);
        }

        function getLastDataHash() constant returns (bytes32) {
                return callDatabase.lastDataHash;
        }

        function getLastDataLength() constant returns (uint) {
                return callDatabase.lastDataLength;
        }

        function getLastData() constant returns (bytes) {
                return callDatabase.lastData;
        }

        /*
         *  Call execution API
         */
        function doCall(bytes32 callKey) public {
                ScheduledCallLib.doCall(callDatabase, callKey, msg.sender);
        }

        /*
         *  Call Scheduling API
         */
        function getMinimumGracePeriod() constant returns (uint) {
                return ScheduledCallLib.getMinimumGracePeriod();
        }

        function scheduleCall(address contractAddress, bytes4 abiSignature, bytes32 dataHash, uint targetBlock) public {
                /*
                 *  Schedule call with gracePeriod defaulted to 255 and nonce
                 *  defaulted to 0.
                 */
                scheduleCall(contractAddress, abiSignature, dataHash, targetBlock, 255, 0);
        }

        function scheduleCall(address contractAddress, bytes4 abiSignature, bytes32 dataHash, uint targetBlock, uint8 gracePeriod) public {
                /*
                 *  Schedule call with nonce defaulted to 0.
                 */
                scheduleCall(contractAddress, abiSignature, dataHash, targetBlock, gracePeriod, 0);
        }

        function scheduleCall(address contractAddress, bytes4 abiSignature, bytes32 dataHash, uint targetBlock, uint8 gracePeriod, uint nonce) public {
                /*
                 * Primary API for scheduling a call.  Prior to calling this
                 * the data should already have been registered through the
                 * `registerData` API.
                 */
                bytes15 reason = ScheduledCallLib.scheduleCall(callDatabase, msg.sender, contractAddress, abiSignature, dataHash, targetBlock, gracePeriod, nonce);
                bytes32 callKey = ScheduledCallLib.computeCallKey(msg.sender, contractAddress, abiSignature, dataHash, targetBlock, gracePeriod, nonce);

                if (reason != 0x0) {
                        ScheduledCallLib.CallRejected(callKey, reason);
                }
                else {
                        ScheduledCallLib.CallScheduled(callKey);
                }
        }

        function cancelCall(bytes32 callKey) public {
                if (ScheduledCallLib.cancelCall(callDatabase, callKey, address(msg.sender))) {
                        ScheduledCallLib.CallCancelled(callKey);
                }
        }

        /*
         *  Next Call API
         */
        function getCallWindowSize() constant returns (uint) {
                return ScheduledCallLib.getCallWindowSize();
        }

        function getGenerationIdForCall(bytes32 callKey) constant returns (uint) {
                return ScheduledCallLib.getGenerationIdForCall(callDatabase, callKey);
        }

        function getDesignatedCaller(bytes32 callKey, uint blockNumber) constant returns (address) {
                return ScheduledCallLib.getDesignatedCaller(callDatabase, callKey, blockNumber);
        }

        function getNextCall(uint blockNumber) constant returns (bytes32) {
                return GroveLib.query(callDatabase.callIndex, ">=", int(blockNumber));
        }

        function getNextCallSibling(bytes32 callKey) constant returns (bytes32) {
                return GroveLib.getNextNode(callDatabase.callIndex, callKey);
        }
}
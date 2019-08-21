// Grove v0.2


/// @title GroveLib - Library for queriable indexed ordered data.
/// @author PiperMerriam -
library GroveLib {
        /*
         *  Indexes for ordered data
         *
         *  Address: 0x7c1eb207c07e7ab13cf245585bd03d0fa478d034
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
            return (index.nodes[id].height > 0);
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
            nodeToDelete.height = 0;

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


// Accounting v0.1 (not the same as the 0.1 release of this library)

/// @title Accounting Lib - Accounting utilities
/// @author Piper Merriam -
library AccountingLib {
        /*
         *  Address: 0x89efe605e9ecbe22849cd85d5449cc946c26f8f3
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

        uint constant DEFAULT_SEND_GAS = 100000;

        function sendRobust(address toAddress, uint value) public returns (bool) {
                if (msg.gas < DEFAULT_SEND_GAS) {
                    return sendRobust(toAddress, value, msg.gas);
                }
                return sendRobust(toAddress, value, DEFAULT_SEND_GAS);
        }

        function sendRobust(address toAddress, uint value, uint maxGas) public returns (bool) {
                if (value > 0 && !toAddress.send(value)) {
                        // Potentially sending money to a contract that
                        // has a fallback function.  So instead, try
                        // tranferring the funds with the call api.
                        if (!toAddress.call.gas(maxGas).value(value)()) {
                                return false;
                        }
                }
                return true;
        }
}


library CallLib {
    /*
     *  Address: 0x1deeda36e15ec9e80f3d7414d67a4803ae45fc80
     */
    struct Call {
        address contractAddress;
        bytes4 abiSignature;
        bytes callData;
        uint callValue;
        uint anchorGasPrice;
        uint requiredGas;
        uint16 requiredStackDepth;

        address claimer;
        uint claimAmount;
        uint claimerDeposit;

        bool wasSuccessful;
        bool wasCalled;
        bool isCancelled;
    }

    enum State {
        Pending,
        Unclaimed,
        Claimed,
        Frozen,
        Callable,
        Executed,
        Cancelled,
        Missed
    }

    function state(Call storage self) constant returns (State) {
        if (self.isCancelled) return State.Cancelled;
        if (self.wasCalled) return State.Executed;

        var call = FutureBlockCall(this);

        if (block.number + CLAIM_GROWTH_WINDOW + MAXIMUM_CLAIM_WINDOW + BEFORE_CALL_FREEZE_WINDOW < call.targetBlock()) return State.Pending;
        if (block.number + BEFORE_CALL_FREEZE_WINDOW < call.targetBlock()) {
            if (self.claimer == 0x0) {
                return State.Unclaimed;
            }
            else {
                return State.Claimed;
            }
        }
        if (block.number < call.targetBlock()) return State.Frozen;
        if (block.number < call.targetBlock() + call.gracePeriod()) return State.Callable;
        return State.Missed;
    }

    // The number of blocks that each caller in the pool has to complete their
    // call.
    uint constant CALL_WINDOW_SIZE = 16;

    address constant creator = 0xd3cda913deb6f67967b99d67acdfa1712c293601;

    function extractCallData(Call storage call, bytes data) public {
        call.callData.length = data.length - 4;
        if (data.length > 4) {
                for (uint i = 0; i < call.callData.length; i++) {
                        call.callData[i] = data[i + 4];
                }
        }
    }

    uint constant GAS_PER_DEPTH = 700;

    function checkDepth(uint n) constant returns (bool) {
        if (n == 0) return true;
        return address(this).call.gas(GAS_PER_DEPTH * n)(bytes4(sha3("__dig(uint256)")), n - 1);
    }

    function sendSafe(address to_address, uint value) public returns (uint) {
        if (value > address(this).balance) {
            value = address(this).balance;
        }
        if (value > 0) {
            AccountingLib.sendRobust(to_address, value);
            return value;
        }
        return 0;
    }

    function getGasScalar(uint base_gas_price, uint gas_price) constant returns (uint) {
        /*
        *  Return a number between 0 - 200 to scale the donation based on the
        *  gas price set for the calling transaction as compared to the gas
        *  price of the scheduling transaction.
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
        if (gas_price > base_gas_price) {
            return 100 * base_gas_price / gas_price;
        }
        else {
            return 200 - 100 * base_gas_price / (2 * base_gas_price - gas_price);
        }
    }

    event CallExecuted(address indexed executor, uint gasCost, uint payment, uint donation, bool success);

    bytes4 constant EMPTY_SIGNATURE = 0x0000;

    event CallAborted(address executor, bytes32 reason);

    function execute(Call storage self,
                     uint start_gas,
                     address executor,
                     uint overhead,
                     uint extraGas) public {
        FutureCall call = FutureCall(this);

        // Mark the call has having been executed.
        self.wasCalled = true;

        // Make the call
        if (self.abiSignature == EMPTY_SIGNATURE && self.callData.length == 0) {
            self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)();
        }
        else if (self.abiSignature == EMPTY_SIGNATURE) {
            self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.callData);
        }
        else if (self.callData.length == 0) {
            self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature);
        }
        else {
            self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature, self.callData);
        }

        call.origin().call(bytes4(sha3("updateDefaultPayment()")));

        // Compute the scalar (0 - 200) for the donation.
        uint gasScalar = getGasScalar(self.anchorGasPrice, tx.gasprice);

        uint basePayment;
        if (self.claimer == executor) {
            basePayment = self.claimAmount;
        }
        else {
            basePayment = call.basePayment();
        }
        uint payment = self.claimerDeposit + basePayment * gasScalar / 100;
        uint donation = call.baseDonation() * gasScalar / 100;

        // zero out the deposit
        self.claimerDeposit = 0;

        // Log how much gas this call used.  EXTRA_CALL_GAS is a fixed
        // amount that represents the gas usage of the commands that
        // happen after this line.
        uint gasCost = tx.gasprice * (start_gas - msg.gas + extraGas);

        // Now we need to pay the executor as well as keep donation.
        payment = sendSafe(executor, payment + gasCost);
        donation = sendSafe(creator, donation);

        // Log execution
        CallExecuted(executor, gasCost, payment, donation, self.wasSuccessful);
    }

    event Cancelled(address indexed cancelled_by);

    function cancel(Call storage self, address sender) public {
        Cancelled(sender);
        if (self.claimerDeposit >= 0) {
            sendSafe(self.claimer, self.claimerDeposit);
        }
        var call = FutureCall(this);
        sendSafe(call.schedulerAddress(), address(this).balance);
        self.isCancelled = true;
    }

    /*
     *  Bid API
     *  - Gas costs for this transaction are not covered so it
     *    must be up to the call executors to ensure that their actions
     *    remain profitable.  Any form of bidding war is likely to eat into
     *    profits.
     */
    event Claimed(address executor, uint claimAmount);

    // The duration (in blocks) during which the maximum claim will slowly rise
    // towards the basePayment amount.
    uint constant CLAIM_GROWTH_WINDOW = 240;

    // The duration (in blocks) after the CLAIM_WINDOW that claiming will
    // remain open.
    uint constant MAXIMUM_CLAIM_WINDOW = 15;

    // The duration (in blocks) before the call's target block during which
    // all actions are frozen.  This includes claiming, cancellation,
    // registering call data.
    uint constant BEFORE_CALL_FREEZE_WINDOW = 10;

    /*
     *  The maximum allowed claim amount slowly rises across a window of
     *  blocks CLAIM_GROWTH_WINDOW prior to the call.  No claimer is
     *  allowed to claim above this value.  This is intended to prevent
     *  bidding wars in that each caller should know how much they are
     *  willing to execute a call for.
     */
    function getClaimAmountForBlock(uint block_number) constant returns (uint) {
        /*
         *   [--growth-window--][--max-window--][--freeze-window--]
         *
         *
         */
        var call = FutureBlockCall(this);

        uint cutoff = call.targetBlock() - BEFORE_CALL_FREEZE_WINDOW;

        // claim window has closed
        if (block_number > cutoff) return call.basePayment();

        cutoff -= MAXIMUM_CLAIM_WINDOW;

        // in the maximum claim window.
        if (block_number > cutoff) return call.basePayment();

        cutoff -= CLAIM_GROWTH_WINDOW;

        if (block_number > cutoff) {
            uint x = block_number - cutoff;

            return call.basePayment() * x / CLAIM_GROWTH_WINDOW;
        }

        return 0;
    }

    function lastClaimBlock() constant returns (uint) {
        var call = FutureBlockCall(this);
        return call.targetBlock() - BEFORE_CALL_FREEZE_WINDOW;
    }

    function maxClaimBlock() constant returns (uint) {
        return lastClaimBlock() - MAXIMUM_CLAIM_WINDOW;
    }

    function firstClaimBlock() constant returns (uint) {
        return maxClaimBlock() - CLAIM_GROWTH_WINDOW;
    }

    function claim(Call storage self, address executor, uint deposit_amount, uint basePayment) public returns (bool) {
        /*
         *  Warning! this does not check whether the function is already
         *  claimed or whether we are within the claim window.  This must be
         *  done at the contract level.
         */
        // Insufficient Deposit
        if (deposit_amount < 2 * basePayment) return false;

        self.claimAmount = getClaimAmountForBlock(block.number);
        self.claimer = executor;
        self.claimerDeposit = deposit_amount;

        // Log the claim.
        Claimed(executor, self.claimAmount);
    }

    function checkExecutionAuthorization(Call storage self, address executor, uint block_number) returns (bool) {
        /*
        *  Check whether the given `executor` is authorized.
        */
        var call = FutureBlockCall(this);

        uint targetBlock = call.targetBlock();

        // Invalid, not in call window.
        if (block_number < targetBlock || block_number > targetBlock + call.gracePeriod()) throw;

        // Within the reserved call window so if there is a claimer, the
        // executor must be the claimdor.
        if (block_number - targetBlock < CALL_WINDOW_SIZE) {
        return (self.claimer == 0x0 || self.claimer == executor);
        }

        // Must be in the free-for-all period.
        return true;
    }

    function isCancellable(Call storage self, address caller) returns (bool) {
        var _state = state(self);
        var call = FutureBlockCall(this);

        if (_state == State.Pending && caller == call.schedulerAddress()) {
            return true;
        }

        if (_state == State.Missed) return true;

        return false;
    }

    function beforeExecuteForFutureBlockCall(Call storage self, address executor, uint startGas) returns (bool) {
        bytes32 reason;

        var call = FutureBlockCall(this);

        if (startGas < self.requiredGas) {
            // The executor has not provided sufficient gas
            reason = "NOT_ENOUGH_GAS";
        }
        else if (self.wasCalled) {
            // Not being called within call window.
            reason = "ALREADY_CALLED";
        }
        else if (block.number < call.targetBlock() || block.number > call.targetBlock() + call.gracePeriod()) {
            // Not being called within call window.
            reason = "NOT_IN_CALL_WINDOW";
        }
        else if (!checkExecutionAuthorization(self, executor, block.number)) {
            // Someone has claimed this call and they currently have exclusive
            // rights to execute it.
            reason = "NOT_AUTHORIZED";
        }
        else if (self.requiredStackDepth > 0 && executor != tx.origin && !checkDepth(self.requiredStackDepth)) {
            reason = "STACK_TOO_DEEP";
        }

        if (reason != 0x0) {
            CallAborted(executor, reason);
            return false;
        }

        return true;
    }
}


contract FutureCall {
    // The author (Piper Merriam) address.
    address constant creator = 0xd3cda913deb6f67967b99d67acdfa1712c293601;

    address public schedulerAddress;

    uint public basePayment;
    uint public baseDonation;

    CallLib.Call call;

    address public origin;

    function FutureCall(address _schedulerAddress,
                        uint _requiredGas,
                        uint16 _requiredStackDepth,
                        address _contractAddress,
                        bytes4 _abiSignature,
                        bytes _callData,
                        uint _callValue,
                        uint _basePayment,
                        uint _baseDonation)
    {
        origin = msg.sender;
        schedulerAddress = _schedulerAddress;

        basePayment = _basePayment;
        baseDonation = _baseDonation;

        call.requiredGas = _requiredGas;
        call.requiredStackDepth = _requiredStackDepth;
        call.anchorGasPrice = tx.gasprice;
        call.contractAddress = _contractAddress;
        call.abiSignature = _abiSignature;
        call.callData = _callData;
        call.callValue = _callValue;
    }

    enum State {
        Pending,
        Unclaimed,
        Claimed,
        Frozen,
        Callable,
        Executed,
        Cancelled,
        Missed
    }

    modifier in_state(State _state) { if (state() == _state) _ }

    function state() constant returns (State) {
        return State(CallLib.state(call));
    }

    /*
     *  API for FutureXXXXCalls to implement.
     */
    function beforeExecute(address executor, uint startGas) public returns (bool);
    function afterExecute(address executor) internal;
    function getOverhead() constant returns (uint);
    function getExtraGas() constant returns (uint);

    /*
     *  Data accessor functions.
     */
    function contractAddress() constant returns (address) {
        return call.contractAddress;
    }

    function abiSignature() constant returns (bytes4) {
        return call.abiSignature;
    }

    function callData() constant returns (bytes) {
        return call.callData;
    }

    function callValue() constant returns (uint) {
        return call.callValue;
    }

    function anchorGasPrice() constant returns (uint) {
        return call.anchorGasPrice;
    }

    function requiredGas() constant returns (uint) {
        return call.requiredGas;
    }

    function requiredStackDepth() constant returns (uint16) {
        return call.requiredStackDepth;
    }

    function claimer() constant returns (address) {
        return call.claimer;
    }

    function claimAmount() constant returns (uint) {
        return call.claimAmount;
    }

    function claimerDeposit() constant returns (uint) {
        return call.claimerDeposit;
    }

    function wasSuccessful() constant returns (bool) {
        return call.wasSuccessful;
    }

    function wasCalled() constant returns (bool) {
        return call.wasCalled;
    }

    function isCancelled() constant returns (bool) {
        return call.isCancelled;
    }

    /*
     *  Claim API helpers
     */
    function getClaimAmountForBlock() constant returns (uint) {
        return CallLib.getClaimAmountForBlock(block.number);
    }

    function getClaimAmountForBlock(uint block_number) constant returns (uint) {
        return CallLib.getClaimAmountForBlock(block_number);
    }

    /*
     *  Call Data registration
     */
    function () returns (bool) {
        /*
         * Fallback to allow sending funds to this contract.
         * (also allows registering raw call data)
         */
        // only scheduler can register call data.
        if (msg.sender != schedulerAddress) return false;
        // cannot write over call data
        if (call.callData.length > 0) return false;

        var _state = state();
        if (_state != State.Pending && _state != State.Unclaimed && _state != State.Claimed) return false;

        call.callData = msg.data;
        return true;
    }

    function registerData() public returns (bool) {
        // only scheduler can register call data.
        if (msg.sender != schedulerAddress) return false;
        // cannot write over call data
        if (call.callData.length > 0) return false;

        var _state = state();
        if (_state != State.Pending && _state != State.Unclaimed && _state != State.Claimed) return false;

        CallLib.extractCallData(call, msg.data);
    }

    function firstClaimBlock() constant returns (uint) {
        return CallLib.firstClaimBlock();
    }

    function maxClaimBlock() constant returns (uint) {
        return CallLib.maxClaimBlock();
    }

    function lastClaimBlock() constant returns (uint) {
        return CallLib.lastClaimBlock();
    }

    function claim() public in_state(State.Unclaimed) returns (bool) {
        bool success = CallLib.claim(call, msg.sender, msg.value, basePayment);
        if (!success) {
            if (!AccountingLib.sendRobust(msg.sender, msg.value)) throw;
        }
        return success;
    }

    function checkExecutionAuthorization(address executor, uint block_number) constant returns (bool) {
        return CallLib.checkExecutionAuthorization(call, executor, block_number);
    }

    function sendSafe(address to_address, uint value) internal {
        CallLib.sendSafe(to_address, value);
    }

    function execute() public in_state(State.Callable) {
        uint start_gas = msg.gas;

        // Check that the call should be executed now.
        if (!beforeExecute(msg.sender, start_gas)) return;

        // Execute the call
        CallLib.execute(call, start_gas, msg.sender, getOverhead(), getExtraGas());

        // Any logic that needs to occur after the call has executed should
        // go in afterExecute
        afterExecute(msg.sender);
    }
}


contract FutureBlockCall is FutureCall {
    uint public targetBlock;
    uint8 public gracePeriod;

    uint constant CALL_API_VERSION = 2;

    function callAPIVersion() constant returns (uint) {
        return CALL_API_VERSION;
    }

    function FutureBlockCall(address _schedulerAddress,
                             uint _targetBlock,
                             uint8 _gracePeriod,
                             address _contractAddress,
                             bytes4 _abiSignature,
                             bytes _callData,
                             uint _callValue,
                             uint _requiredGas,
                             uint16 _requiredStackDepth,
                             uint _basePayment,
                             uint _baseDonation)
        FutureCall(_schedulerAddress, _requiredGas, _requiredStackDepth, _contractAddress, _abiSignature, _callData, _callValue, _basePayment, _baseDonation)
    {
        // parent contract FutureCall
        schedulerAddress = _schedulerAddress;

        targetBlock = _targetBlock;
        gracePeriod = _gracePeriod;
    }

    uint constant GAS_PER_DEPTH = 700;

    function __dig(uint n) constant returns (bool) {
        if (n == 0) return true;
        if (!address(this).callcode(bytes4(sha3("__dig(uint256)")), n - 1)) throw;
    }


    function beforeExecute(address executor, uint startGas) public returns (bool) {
        return CallLib.beforeExecuteForFutureBlockCall(call, executor, startGas);
    }

    function afterExecute(address executor) internal {
        // Refund any leftover funds.
        CallLib.sendSafe(schedulerAddress, address(this).balance);
    }

    uint constant GAS_OVERHEAD = 100000;

    function getOverhead() constant returns (uint) {
            return GAS_OVERHEAD;
    }

    uint constant EXTRA_GAS = 77000;

    function getExtraGas() constant returns (uint) {
            return EXTRA_GAS;
    }

    uint constant CLAIM_GROWTH_WINDOW = 240;
    uint constant MAXIMUM_CLAIM_WINDOW = 15;
    uint constant BEFORE_CALL_FREEZE_WINDOW = 10;

    function isCancellable() constant public returns (bool) {
        return CallLib.isCancellable(call, msg.sender);
    }

    function cancel() public {
        if (CallLib.isCancellable(call, msg.sender)) {
            CallLib.cancel(call, msg.sender);
        }
    }
}


library SchedulerLib {
    /*
     *  Address: 0xe54d323f9ef17c1f0dede47ecc86a9718fe5ea34
     */
    /*
     *  Call Scheduling API
     */
    function version() constant returns (uint16, uint16, uint16) {
        return (0, 7, 0);
    }

    // Ten minutes into the future.
    uint constant MIN_BLOCKS_IN_FUTURE = 10;

    // max of uint8
    uint8 constant DEFAULT_GRACE_PERIOD = 255;

    // The minimum gas required to execute a scheduled call on a function that
    // does almost nothing.  This is an approximation and assumes the worst
    // case scenario for gas consumption.
    //
    // Measured Minimum is closer to 80,000
    uint constant MINIMUM_CALL_GAS = 200000;

    // The minimum depth required to execute a call.
    uint16 constant MINIMUM_STACK_CHECK = 10;

    // The maximum possible depth that stack depth checking can achieve.
    // Actual check limit is 1021.  Actual call limit is 1021
    uint16 constant MAXIMUM_STACK_CHECK = 1000;

    event CallScheduled(address call_address);

    event CallRejected(address indexed schedulerAddress, bytes32 reason);

    uint constant CALL_WINDOW_SIZE = 16;

    function getMinimumStackCheck() constant returns (uint16) {
        return MINIMUM_STACK_CHECK;
    }

    function getMaximumStackCheck() constant returns (uint16) {
        return MAXIMUM_STACK_CHECK;
    }

    function getCallWindowSize() constant returns (uint) {
        return CALL_WINDOW_SIZE;
    }

    function getMinimumGracePeriod() constant returns (uint) {
        return 2 * CALL_WINDOW_SIZE;
    }

    function getDefaultGracePeriod() constant returns (uint8) {
        return DEFAULT_GRACE_PERIOD;
    }

    function getMinimumCallGas() constant returns (uint) {
        return MINIMUM_CALL_GAS;
    }

    function getMaximumCallGas() constant returns (uint) {
        return block.gaslimit - getMinimumCallGas();
    }

    function getMinimumCallCost(uint basePayment, uint baseDonation) constant returns (uint) {
        return 2 * (baseDonation + basePayment) + MINIMUM_CALL_GAS * tx.gasprice;
    }

    function getFirstSchedulableBlock() constant returns (uint) {
        return block.number + MIN_BLOCKS_IN_FUTURE;
    }

    function getMinimumEndowment(uint basePayment,
                                 uint baseDonation,
                                 uint callValue,
                                 uint requiredGas) constant returns (uint endowment) {
            endowment += tx.gasprice * requiredGas;
            endowment += 2 * (basePayment + baseDonation);
            endowment += callValue;

            return endowment;
    }

    struct CallConfig {
        address schedulerAddress;
        address contractAddress;
        bytes4 abiSignature;
        bytes callData;
        uint callValue;
        uint8 gracePeriod;
        uint16 requiredStackDepth;
        uint targetBlock;
        uint requiredGas;
        uint basePayment;
        uint baseDonation;
        uint endowment;
    }

    function scheduleCall(GroveLib.Index storage callIndex,
                          address schedulerAddress,
                          address contractAddress,
                          bytes4 abiSignature,
                          bytes callData,
                          uint8 gracePeriod,
                          uint16 requiredStackDepth,
                          uint callValue,
                          uint targetBlock,
                          uint requiredGas,
                          uint basePayment,
                          uint baseDonation,
                          uint endowment) public returns (address) {
        CallConfig memory callConfig = CallConfig({
            schedulerAddress: schedulerAddress,
            contractAddress: contractAddress,
            abiSignature: abiSignature,
            callData: callData,
            gracePeriod: gracePeriod,
            requiredStackDepth: requiredStackDepth,
            callValue: callValue,
            targetBlock: targetBlock,
            requiredGas: requiredGas,
            basePayment: basePayment,
            baseDonation: baseDonation,
            endowment: endowment,
        });
        return _scheduleCall(callIndex, callConfig);
    }

    function scheduleCall(GroveLib.Index storage callIndex,
                          address[2] addresses,
                          bytes4 abiSignature,
                          bytes callData,
                          uint8 gracePeriod,
                          uint16 requiredStackDepth,
                          uint[6] uints) public returns (address) {
        CallConfig memory callConfig = CallConfig({
            schedulerAddress: addresses[0],
            contractAddress: addresses[1],
            abiSignature: abiSignature,
            callData: callData,
            gracePeriod: gracePeriod,
            requiredStackDepth: requiredStackDepth,
            callValue: uints[0],
            targetBlock: uints[1],
            requiredGas: uints[2],
            basePayment: uints[3],
            baseDonation: uints[4],
            endowment: uints[5],
        });
        return _scheduleCall(callIndex, callConfig);

    }

    function _scheduleCall(GroveLib.Index storage callIndex, CallConfig memory callConfig) internal returns (address) {
        /*
        * Primary API for scheduling a call.
        *
        * - No sooner than MIN_BLOCKS_IN_FUTURE
        * - Grace Period must be longer than the minimum grace period.
        * - msg.value must be >= MIN_GAS * tx.gasprice + 2 * (baseDonation + basePayment)
        */
        bytes32 reason;

        if (callConfig.targetBlock < block.number + MIN_BLOCKS_IN_FUTURE) {
            // Don't allow scheduling further than
            // MIN_BLOCKS_IN_FUTURE
            reason = "TOO_SOON";
        }
        else if (getMinimumStackCheck() > callConfig.requiredStackDepth || callConfig.requiredStackDepth > getMaximumStackCheck()) {
            // Cannot require stack depth greater than MAXIMUM_STACK_CHECK or
            // less than MINIMUM_STACK_CHECK
            reason = "STACK_CHECK_OUT_OF_RANGE";
        }
        else if (callConfig.gracePeriod < getMinimumGracePeriod()) {
            reason = "GRACE_TOO_SHORT";
        }
        else if (callConfig.requiredGas < getMinimumCallGas() || callConfig.requiredGas > getMaximumCallGas()) {
            reason = "REQUIRED_GAS_OUT_OF_RANGE";
        }
        else if (callConfig.endowment < getMinimumEndowment(callConfig.basePayment, callConfig.baseDonation, callConfig.callValue, callConfig.requiredGas)) {
            reason = "INSUFFICIENT_FUNDS";
        }

        if (reason != 0x0) {
            CallRejected(callConfig.schedulerAddress, reason);
            AccountingLib.sendRobust(callConfig.schedulerAddress, callConfig.endowment);
            return;
        }

        var call = (new FutureBlockCall).value(callConfig.endowment)(
                callConfig.schedulerAddress,
                callConfig.targetBlock,
                callConfig.gracePeriod,
                callConfig.contractAddress,
                callConfig.abiSignature,
                callConfig.callData,
                callConfig.callValue,
                callConfig.requiredGas,
                callConfig.requiredStackDepth,
                callConfig.basePayment,
                callConfig.baseDonation
        );

        // Put the call into the grove index.
        GroveLib.insert(callIndex, bytes32(address(call)), int(call.targetBlock()));

        CallScheduled(address(call));

        return address(call);
    }
}


contract Scheduler {
    /*
     *  Address: 0x6c8f2a135f6ed072de4503bd7c4999a1a17f824b
     */

    // The starting value (0.01 USD at 1eth:$2 exchange rate)
    uint constant INITIAL_DEFAUlT_PAYMENT = 5 finney;

    uint public defaultPayment;

    function Scheduler() {
        defaultPayment = INITIAL_DEFAUlT_PAYMENT;
    }

    // callIndex tracks the ordering of scheduled calls based on their block numbers.
    GroveLib.Index callIndex;

    uint constant CALL_API_VERSION = 7;

    function callAPIVersion() constant returns (uint) {
        return CALL_API_VERSION;
    }

    /*
     *  Call Scheduling
     */
    function getMinimumGracePeriod() constant returns (uint) {
        return SchedulerLib.getMinimumGracePeriod();
    }

    // Default payment and donation values
    modifier only_known_call { if (isKnownCall(msg.sender)) _ }

    function updateDefaultPayment() public only_known_call {
        var call = FutureBlockCall(msg.sender);
        var basePayment = call.basePayment();

        if (call.wasCalled() && call.claimer() != 0x0 && basePayment > 0 && defaultPayment > 1) {
            var index = call.claimAmount() * 100 / basePayment;

            if (index > 66 && defaultPayment <= basePayment) {
                // increase by 0.01%
                defaultPayment = defaultPayment * 10001 / 10000;
            }
            else if (index < 33 && defaultPayment >= basePayment) {
                // decrease by 0.01%
                defaultPayment = defaultPayment * 9999 / 10000;
            }
        }
    }

    function getDefaultDonation() constant returns (uint) {
        return defaultPayment / 100;
    }

    function getMinimumCallGas() constant returns (uint) {
        return SchedulerLib.getMinimumCallGas();
    }

    function getMaximumCallGas() constant returns (uint) {
        return SchedulerLib.getMaximumCallGas();
    }

    function getMinimumEndowment() constant returns (uint) {
        return SchedulerLib.getMinimumEndowment(defaultPayment, getDefaultDonation(), 0, getDefaultRequiredGas());
    }

    function getMinimumEndowment(uint basePayment) constant returns (uint) {
        return SchedulerLib.getMinimumEndowment(basePayment, getDefaultDonation(), 0, getDefaultRequiredGas());
    }

    function getMinimumEndowment(uint basePayment, uint baseDonation) constant returns (uint) {
        return SchedulerLib.getMinimumEndowment(basePayment, baseDonation, 0, getDefaultRequiredGas());
    }

    function getMinimumEndowment(uint basePayment, uint baseDonation, uint callValue) constant returns (uint) {
        return SchedulerLib.getMinimumEndowment(basePayment, baseDonation, callValue, getDefaultRequiredGas());
    }

    function getMinimumEndowment(uint basePayment, uint baseDonation, uint callValue, uint requiredGas) constant returns (uint) {
        return SchedulerLib.getMinimumEndowment(basePayment, baseDonation, callValue, requiredGas);
    }

    function isKnownCall(address callAddress) constant returns (bool) {
        return GroveLib.exists(callIndex, bytes32(callAddress));
    }

    function getFirstSchedulableBlock() constant returns (uint) {
        return SchedulerLib.getFirstSchedulableBlock();
    }

    function getMinimumStackCheck() constant returns (uint16) {
        return SchedulerLib.getMinimumStackCheck();
    }

    function getMaximumStackCheck() constant returns (uint16) {
        return SchedulerLib.getMaximumStackCheck();
    }

    function getDefaultStackCheck() constant returns (uint16) {
        return getMinimumStackCheck();
    }

    function getDefaultRequiredGas() constant returns (uint) {
        return SchedulerLib.getMinimumCallGas();
    }

    function getDefaultGracePeriod() constant returns (uint8) {
        return SchedulerLib.getDefaultGracePeriod();
    }

    bytes constant EMPTY_CALL_DATA = "";
    uint constant DEFAULT_CALL_VALUE = 0;
    bytes4 constant DEFAULT_FN_SIGNATURE = 0x0000;

    function scheduleCall() public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            DEFAULT_FN_SIGNATURE, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, getFirstSchedulableBlock(), getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(uint targetBlock) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            DEFAULT_FN_SIGNATURE, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(bytes callData) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            DEFAULT_FN_SIGNATURE, callData, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, getFirstSchedulableBlock(), getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(bytes4 abiSignature,
                          bytes callData) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            abiSignature, callData, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, getFirstSchedulableBlock(), getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(bytes4 abiSignature) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            abiSignature, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, getFirstSchedulableBlock(), getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            DEFAULT_FN_SIGNATURE, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, getFirstSchedulableBlock(), getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, getFirstSchedulableBlock(), getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          uint callValue,
                          bytes4 abiSignature) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            callValue, getFirstSchedulableBlock(), getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          bytes callData) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, callData, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, getFirstSchedulableBlock(), getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          uint callValue,
                          bytes callData) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, callData, getDefaultGracePeriod(), getDefaultStackCheck(),
            callValue, getFirstSchedulableBlock(), getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(uint callValue,
                          address contractAddress) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            DEFAULT_FN_SIGNATURE, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            callValue, getFirstSchedulableBlock(), getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          uint targetBlock) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            DEFAULT_FN_SIGNATURE, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          uint targetBlock,
                          uint callValue) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            DEFAULT_FN_SIGNATURE, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            callValue, targetBlock, getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(bytes4 abiSignature,
                          uint targetBlock) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            abiSignature, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          uint targetBlock) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(bytes4 abiSignature,
                          bytes callData,
                          uint targetBlock) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            abiSignature, callData, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          bytes callData,
                          uint targetBlock) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, callData, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          uint callValue,
                          bytes callData,
                          uint targetBlock) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, callData, getDefaultGracePeriod(), getDefaultStackCheck(),
            callValue, targetBlock, getDefaultRequiredGas(), defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(bytes4 abiSignature,
                          uint targetBlock,
                          uint requiredGas) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            abiSignature, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, requiredGas, defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          uint targetBlock,
                          uint requiredGas) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, EMPTY_CALL_DATA, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, requiredGas, defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(bytes4 abiSignature,
                          bytes callData,
                          uint targetBlock,
                          uint requiredGas) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            abiSignature, callData, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, requiredGas, defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          bytes callData,
                          uint targetBlock,
                          uint requiredGas) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, callData, getDefaultGracePeriod(), getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, requiredGas, defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(bytes4 abiSignature,
                          uint targetBlock,
                          uint requiredGas,
                          uint8 gracePeriod) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            abiSignature, EMPTY_CALL_DATA, gracePeriod, getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, requiredGas, defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          uint callValue,
                          bytes4 abiSignature,
                          uint targetBlock,
                          uint requiredGas,
                          uint8 gracePeriod) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, EMPTY_CALL_DATA, gracePeriod, getDefaultStackCheck(),
            callValue, targetBlock, requiredGas, defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          uint targetBlock,
                          uint requiredGas,
                          uint8 gracePeriod) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, EMPTY_CALL_DATA, gracePeriod, getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, requiredGas, defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          bytes callData,
                          uint targetBlock,
                          uint requiredGas,
                          uint8 gracePeriod) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, callData, gracePeriod, getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, requiredGas, defaultPayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(bytes4 abiSignature,
                          uint targetBlock,
                          uint requiredGas,
                          uint8 gracePeriod,
                          uint basePayment) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            abiSignature, EMPTY_CALL_DATA, gracePeriod, getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, requiredGas, basePayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          uint callValue,
                          bytes4 abiSignature,
                          uint targetBlock,
                          uint requiredGas,
                          uint8 gracePeriod,
                          uint basePayment) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, EMPTY_CALL_DATA, gracePeriod, getDefaultStackCheck(),
            callValue, targetBlock, requiredGas, basePayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          uint targetBlock,
                          uint requiredGas,
                          uint8 gracePeriod,
                          uint basePayment) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, EMPTY_CALL_DATA, gracePeriod, getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, requiredGas, basePayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(bytes4 abiSignature,
                          bytes callData,
                          uint targetBlock,
                          uint requiredGas,
                          uint8 gracePeriod,
                          uint basePayment) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            abiSignature, callData, gracePeriod, getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, requiredGas, basePayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          bytes callData,
                          uint8 gracePeriod,
                          uint[4] args) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, callData, gracePeriod, getDefaultStackCheck(),
            // callValue, targetBlock, requiredGas, basePayment
            args[0], args[1], args[2], args[3], getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          bytes callData,
                          uint targetBlock,
                          uint requiredGas,
                          uint8 gracePeriod,
                          uint basePayment) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, contractAddress,
            abiSignature, callData, gracePeriod, getDefaultStackCheck(),
            DEFAULT_CALL_VALUE, targetBlock, requiredGas, basePayment, getDefaultDonation(), msg.value
        );
    }

    function scheduleCall(bytes4 abiSignature,
                          bytes callData,
                          uint16 requiredStackDepth,
                          uint8 gracePeriod,
                          uint callValue,
                          uint targetBlock,
                          uint requiredGas,
                          uint basePayment,
                          uint baseDonation) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            msg.sender, msg.sender,
            abiSignature, callData, gracePeriod, requiredStackDepth,
            callValue, targetBlock, requiredGas, basePayment, baseDonation, msg.value
        );
    }

    function scheduleCall(address contractAddress,
                          bytes4 abiSignature,
                          bytes callData,
                          uint16 requiredStackDepth,
                          uint8 gracePeriod,
                          uint[5] args) public returns (address) {
        return SchedulerLib.scheduleCall(
            callIndex,
            [msg.sender, contractAddress],
            abiSignature, callData, gracePeriod, requiredStackDepth,
            // callValue, targetBlock, requiredGas, basePayment, baseDonation
            [args[0], args[1], args[2], args[3], args[4], msg.value]
        );
    }

    /*
     *  Next Call API
     */
    function getCallWindowSize() constant returns (uint) {
            return SchedulerLib.getCallWindowSize();
    }

    function getNextCall(uint blockNumber) constant returns (address) {
            return address(GroveLib.query(callIndex, ">=", int(blockNumber)));
    }

    function getNextCallSibling(address callAddress) constant returns (address) {
            return address(GroveLib.getNextNode(callIndex, bytes32(callAddress)));
    }
}
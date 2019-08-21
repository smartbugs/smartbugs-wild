// Grove v0.2


/// @title GroveLib - Library for queriable indexed ordered data.
/// @author PiperMerriam - <pipermerriam@gmail.com>
library GroveLib {
        /*
         *  Indexes for ordered data
         *
         *  Address: 0xd07ce4329b27eb8896c51458468d98a0e4c0394c
         */
        struct Index {
                bytes32 id;
                bytes32 name;
                bytes32 root;
                mapping (bytes32 => Node) nodes;
        }

        struct Node {
                bytes32 nodeId;
                bytes32 indexId;
                bytes32 id;
                int value;
                bytes32 parent;
                bytes32 left;
                bytes32 right;
                uint height;
        }

        /// @dev This is merely a shortcut for `sha3(owner, indexName)`
        /// @param owner The address of the owner of this index.
        /// @param indexName The human readable name for this index.
        function computeIndexId(address owner, bytes32 indexName) constant returns (bytes32) {
                return sha3(owner, indexName);
        }

        /// @dev This is merely a shortcut for `sha3(indexId, id)`
        /// @param indexId The id for the index the node belongs to.
        /// @param id The unique identifier for the data this node represents.
        function computeNodeId(bytes32 indexId, bytes32 id) constant returns (bytes32) {
                return sha3(indexId, id);
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
        /// @param nodeId The id for the node to be looked up.
        function getNodeId(Index storage index, bytes32 nodeId) constant returns (bytes32) {
            return index.nodes[nodeId].id;
        }

        /// @dev Retrieve the index id for the node.
        /// @param index The index that the node is part of.
        /// @param nodeId The id for the node to be looked up.
        function getNodeIndexId(Index storage index, bytes32 nodeId) constant returns (bytes32) {
            return index.nodes[nodeId].indexId;
        }

        /// @dev Retrieve the value for the node.
        /// @param index The index that the node is part of.
        /// @param nodeId The id for the node to be looked up.
        function getNodeValue(Index storage index, bytes32 nodeId) constant returns (int) {
            return index.nodes[nodeId].value;
        }

        /// @dev Retrieve the height of the node.
        /// @param index The index that the node is part of.
        /// @param nodeId The id for the node to be looked up.
        function getNodeHeight(Index storage index, bytes32 nodeId) constant returns (uint) {
            return index.nodes[nodeId].height;
        }

        /// @dev Retrieve the parent id of the node.
        /// @param index The index that the node is part of.
        /// @param nodeId The id for the node to be looked up.
        function getNodeParent(Index storage index, bytes32 nodeId) constant returns (bytes32) {
            return index.nodes[nodeId].parent;
        }

        /// @dev Retrieve the left child id of the node.
        /// @param index The index that the node is part of.
        /// @param nodeId The id for the node to be looked up.
        function getNodeLeftChild(Index storage index, bytes32 nodeId) constant returns (bytes32) {
            return index.nodes[nodeId].left;
        }

        /// @dev Retrieve the right child id of the node.
        /// @param index The index that the node is part of.
        /// @param nodeId The id for the node to be looked up.
        function getNodeRightChild(Index storage index, bytes32 nodeId) constant returns (bytes32) {
            return index.nodes[nodeId].right;
        }

        /// @dev Retrieve the node id of the next node in the tree.
        /// @param index The index that the node is part of.
        /// @param nodeId The id for the node to be looked up.
        function getPreviousNode(Index storage index, bytes32 nodeId) constant returns (bytes32) {
            Node storage currentNode = index.nodes[nodeId];

            if (currentNode.nodeId == 0x0) {
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
                return child.nodeId;
            }

            if (currentNode.parent != 0x0) {
                // Now we trace back up through parent relationships, looking
                // for a link where the child is the right child of it's
                // parent.
                Node storage parent = index.nodes[currentNode.parent];
                child = currentNode;

                while (true) {
                    if (parent.right == child.nodeId) {
                        return parent.nodeId;
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
        /// @param nodeId The id for the node to be looked up.
        function getNextNode(Index storage index, bytes32 nodeId) constant returns (bytes32) {
            Node storage currentNode = index.nodes[nodeId];

            if (currentNode.nodeId == 0x0) {
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
                return child.nodeId;
            }

            if (currentNode.parent != 0x0) {
                // if the node is the left child of it's parent, then the
                // parent is the next one.
                Node storage parent = index.nodes[currentNode.parent];
                child = currentNode;

                while (true) {
                    if (parent.left == child.nodeId) {
                        return parent.nodeId;
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
                bytes32 nodeId = computeNodeId(index.id, id);

                if (index.nodes[nodeId].nodeId == nodeId) {
                    // A node with this id already exists.  If the value is
                    // the same, then just return early, otherwise, remove it
                    // and reinsert it.
                    if (index.nodes[nodeId].value == value) {
                        return;
                    }
                    remove(index, id);
                }

                uint leftHeight;
                uint rightHeight;

                bytes32 previousNodeId = 0x0;

                bytes32 rootNodeId = index.root;

                if (rootNodeId == 0x0) {
                    rootNodeId = nodeId;
                    index.root = nodeId;
                }
                Node storage currentNode = index.nodes[rootNodeId];

                // Do insertion
                while (true) {
                    if (currentNode.indexId == 0x0) {
                        // This is a new unpopulated node.
                        currentNode.nodeId = nodeId;
                        currentNode.parent = previousNodeId;
                        currentNode.indexId = index.id;
                        currentNode.id = id;
                        currentNode.value = value;
                        break;
                    }

                    // Set the previous node id.
                    previousNodeId = currentNode.nodeId;

                    // The new node belongs in the right subtree
                    if (value >= currentNode.value) {
                        if (currentNode.right == 0x0) {
                            currentNode.right = nodeId;
                        }
                        currentNode = index.nodes[currentNode.right];
                        continue;
                    }

                    // The new node belongs in the left subtree.
                    if (currentNode.left == 0x0) {
                        currentNode.left = nodeId;
                    }
                    currentNode = index.nodes[currentNode.left];
                }

                // Rebalance the tree
                _rebalanceTree(index, currentNode.nodeId);
        }

        /// @dev Checks whether a node for the given unique identifier exists within the given index.
        /// @param index The index that should be searched
        /// @param id The unique identifier of the data element to check for.
        function exists(Index storage index, bytes32 id) constant returns (bool) {
            bytes32 nodeId = computeNodeId(index.id, id);
            return (index.nodes[nodeId].nodeId == nodeId);
        }

        /// @dev Remove the node for the given unique identifier from the index.
        /// @param index The index that should be removed
        /// @param id The unique identifier of the data element to remove.
        function remove(Index storage index, bytes32 id) public {
            bytes32 nodeId = computeNodeId(index.id, id);
            
            Node storage replacementNode;
            Node storage parent;
            Node storage child;
            bytes32 rebalanceOrigin;

            Node storage nodeToDelete = index.nodes[nodeId];

            if (nodeToDelete.id != id) {
                // The id does not exist in the tree.
                return;
            }

            if (nodeToDelete.left != 0x0 || nodeToDelete.right != 0x0) {
                // This node is not a leaf node and thus must replace itself in
                // it's tree by either the previous or next node.
                if (nodeToDelete.left != 0x0) {
                    // This node is guaranteed to not have a right child.
                    replacementNode = index.nodes[getPreviousNode(index, nodeToDelete.nodeId)];
                }
                else {
                    // This node is guaranteed to not have a left child.
                    replacementNode = index.nodes[getNextNode(index, nodeToDelete.nodeId)];
                }
                // The replacementNode is guaranteed to have a parent.
                parent = index.nodes[replacementNode.parent];

                // Keep note of the location that our tree rebalancing should
                // start at.
                rebalanceOrigin = replacementNode.nodeId;

                // Join the parent of the replacement node with any subtree of
                // the replacement node.  We can guarantee that the replacement
                // node has at most one subtree because of how getNextNode and
                // getPreviousNode are used.
                if (parent.left == replacementNode.nodeId) {
                    parent.left = replacementNode.right;
                    if (replacementNode.right != 0x0) {
                        child = index.nodes[replacementNode.right];
                        child.parent = parent.nodeId;
                    }
                }
                if (parent.right == replacementNode.nodeId) {
                    parent.right = replacementNode.left;
                    if (replacementNode.left != 0x0) {
                        child = index.nodes[replacementNode.left];
                        child.parent = parent.nodeId;
                    }
                }

                // Now we replace the nodeToDelete with the replacementNode.
                // This includes parent/child relationships for all of the
                // parent, the left child, and the right child.
                replacementNode.parent = nodeToDelete.parent;
                if (nodeToDelete.parent != 0x0) {
                    parent = index.nodes[nodeToDelete.parent];
                    if (parent.left == nodeToDelete.nodeId) {
                        parent.left = replacementNode.nodeId;
                    }
                    if (parent.right == nodeToDelete.nodeId) {
                        parent.right = replacementNode.nodeId;
                    }
                }
                else {
                    // If the node we are deleting is the root node so update
                    // the indexId to root node mapping.
                    index.root = replacementNode.nodeId;
                }

                replacementNode.left = nodeToDelete.left;
                if (nodeToDelete.left != 0x0) {
                    child = index.nodes[nodeToDelete.left];
                    child.parent = replacementNode.nodeId;
                }

                replacementNode.right = nodeToDelete.right;
                if (nodeToDelete.right != 0x0) {
                    child = index.nodes[nodeToDelete.right];
                    child.parent = replacementNode.nodeId;
                }
            }
            else if (nodeToDelete.parent != 0x0) {
                // The node being deleted is a leaf node so we only erase it's
                // parent linkage.
                parent = index.nodes[nodeToDelete.parent];

                if (parent.left == nodeToDelete.nodeId) {
                    parent.left = 0x0;
                }
                if (parent.right == nodeToDelete.nodeId) {
                    parent.right = 0x0;
                }

                // keep note of where the rebalancing should begin.
                rebalanceOrigin = parent.nodeId;
            }
            else {
                // This is both a leaf node and the root node, so we need to
                // unset the root node pointer.
                index.root = 0x0;
            }

            // Now we zero out all of the fields on the nodeToDelete.
            nodeToDelete.id = 0x0;
            nodeToDelete.nodeId = 0x0;
            nodeToDelete.indexId = 0x0;
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

        function _getMaximum(Index storage index, bytes32 nodeId) internal returns (int) {
                Node storage currentNode = index.nodes[nodeId];

                while (true) {
                    if (currentNode.right == 0x0) {
                        return currentNode.value;
                    }
                    currentNode = index.nodes[currentNode.right];
                }
        }

        function _getMinimum(Index storage index, bytes32 nodeId) internal returns (int) {
                Node storage currentNode = index.nodes[nodeId];

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
                                return currentNode.nodeId;
                            }
                            if (_compare(_getMinimum(index, currentNode.right), operator, value)) {
                                // There are still nodes to the right that
                                // match.
                                currentNode = index.nodes[currentNode.right];
                                continue;
                            }
                            return currentNode.nodeId;
                        }

                        if ((operator == GT) || (operator == GTE) || (operator == EQ)) {
                            // Need to keep traversing left until this is no
                            // longer true.
                            if (currentNode.left == 0x0) {
                                return currentNode.nodeId;
                            }
                            if (_compare(_getMaximum(index, currentNode.left), operator, value)) {
                                currentNode = index.nodes[currentNode.left];
                                continue;
                            }
                            return currentNode.nodeId;
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

        function _rebalanceTree(Index storage index, bytes32 nodeId) internal {
            // Trace back up rebalancing the tree and updating heights as
            // needed..
            Node storage currentNode = index.nodes[nodeId];

            while (true) {
                int balanceFactor = _getBalanceFactor(index, currentNode.nodeId);

                if (balanceFactor == 2) {
                    // Right rotation (tree is heavy on the left)
                    if (_getBalanceFactor(index, currentNode.left) == -1) {
                        // The subtree is leaning right so it need to be
                        // rotated left before the current node is rotated
                        // right.
                        _rotateLeft(index, currentNode.left);
                    }
                    _rotateRight(index, currentNode.nodeId);
                }

                if (balanceFactor == -2) {
                    // Left rotation (tree is heavy on the right)
                    if (_getBalanceFactor(index, currentNode.right) == 1) {
                        // The subtree is leaning left so it need to be
                        // rotated right before the current node is rotated
                        // left.
                        _rotateRight(index, currentNode.right);
                    }
                    _rotateLeft(index, currentNode.nodeId);
                }

                if ((-1 <= balanceFactor) && (balanceFactor <= 1)) {
                    _updateNodeHeight(index, currentNode.nodeId);
                }

                if (currentNode.parent == 0x0) {
                    // Reached the root which may be new due to tree
                    // rotation, so set it as the root and then break.
                    break;
                }

                currentNode = index.nodes[currentNode.parent];
            }
        }

        function _getBalanceFactor(Index storage index, bytes32 nodeId) internal returns (int) {
                Node storage node = index.nodes[nodeId];

                return int(index.nodes[node.left].height) - int(index.nodes[node.right].height);
        }

        function _updateNodeHeight(Index storage index, bytes32 nodeId) internal {
                Node storage node = index.nodes[nodeId];

                node.height = max(index.nodes[node.left].height, index.nodes[node.right].height) + 1;
        }

        function _rotateLeft(Index storage index, bytes32 nodeId) internal {
            Node storage originalRoot = index.nodes[nodeId];

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
                if (parent.left == originalRoot.nodeId) {
                    parent.left = newRoot.nodeId;
                }
                if (parent.right == originalRoot.nodeId) {
                    parent.right = newRoot.nodeId;
                }
            }


            if (newRoot.left != 0) {
                // If the new root had a left child, that moves to be the
                // new right child of the original root node
                Node storage leftChild = index.nodes[newRoot.left];
                originalRoot.right = leftChild.nodeId;
                leftChild.parent = originalRoot.nodeId;
            }

            // Update the newRoot's left node to point at the original node.
            originalRoot.parent = newRoot.nodeId;
            newRoot.left = originalRoot.nodeId;

            if (newRoot.parent == 0x0) {
                index.root = newRoot.nodeId;
            }

            // TODO: are both of these updates necessary?
            _updateNodeHeight(index, originalRoot.nodeId);
            _updateNodeHeight(index, newRoot.nodeId);
        }

        function _rotateRight(Index storage index, bytes32 nodeId) internal {
            Node storage originalRoot = index.nodes[nodeId];

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

                if (parent.left == originalRoot.nodeId) {
                    parent.left = newRoot.nodeId;
                }
                if (parent.right == originalRoot.nodeId) {
                    parent.right = newRoot.nodeId;
                }
            }

            if (newRoot.right != 0x0) {
                Node storage rightChild = index.nodes[newRoot.right];
                originalRoot.left = newRoot.right;
                rightChild.parent = originalRoot.nodeId;
            }

            // Update the new root's right node to point to the original node.
            originalRoot.parent = newRoot.nodeId;
            newRoot.right = originalRoot.nodeId;

            if (newRoot.parent == 0x0) {
                index.root = newRoot.nodeId;
            }

            // Recompute heights.
            _updateNodeHeight(index, originalRoot.nodeId);
            _updateNodeHeight(index, newRoot.nodeId);
        }
}


/// @title Grove - queryable indexes for ordered data.
/// @author Piper Merriam <pipermerriam@gmail.com>
contract Grove {
        /*
         *  Indexes for ordered data
         *
         *  Address: 0x8017f24a47c889b1ee80501ff84beb3c017edf0b
         */
        // Map index_id to index
        mapping (bytes32 => GroveLib.Index) index_lookup;

        // Map node_id to index_id.
        mapping (bytes32 => bytes32) node_to_index;

        /// @notice Computes the id for a Grove index which is sha3(owner, indexName)
        /// @param owner The address of the index owner.
        /// @param indexName The name of the index.
        function computeIndexId(address owner, bytes32 indexName) constant returns (bytes32) {
                return GroveLib.computeIndexId(owner, indexName);
        }

        /// @notice Computes the id for a node in a given Grove index which is sha3(indexId, id)
        /// @param indexId The id for the index the node belongs to.
        /// @param id The unique identifier for the data this node represents.
        function computeNodeId(bytes32 indexId, bytes32 id) constant returns (bytes32) {
                return GroveLib.computeNodeId(indexId, id);
        }

        /*
         *  Node getters
         */
        /// @notice Retrieves the name of an index.
        /// @param indexId The id of the index.
        function getIndexName(bytes32 indexId) constant returns (bytes32) {
            return index_lookup[indexId].name;
        }

        /// @notice Retrieves the id of the root node for this index.
        /// @param indexId The id of the index.
        function getIndexRoot(bytes32 indexId) constant returns (bytes32) {
            return index_lookup[indexId].root;
        }


        /// @dev Retrieve the unique identifier this node represents.
        /// @param nodeId The id for the node
        function getNodeId(bytes32 nodeId) constant returns (bytes32) {
            return GroveLib.getNodeId(index_lookup[node_to_index[nodeId]], nodeId);
        }

        /// @dev Retrieve the index id for the node.
        /// @param nodeId The id for the node
        function getNodeIndexId(bytes32 nodeId) constant returns (bytes32) {
            return GroveLib.getNodeIndexId(index_lookup[node_to_index[nodeId]], nodeId);
        }

        /// @dev Retrieve the value of the node.
        /// @param nodeId The id for the node
        function getNodeValue(bytes32 nodeId) constant returns (int) {
            return GroveLib.getNodeValue(index_lookup[node_to_index[nodeId]], nodeId);
        }

        /// @dev Retrieve the height of the node.
        /// @param nodeId The id for the node
        function getNodeHeight(bytes32 nodeId) constant returns (uint) {
            return GroveLib.getNodeHeight(index_lookup[node_to_index[nodeId]], nodeId);
        }

        /// @dev Retrieve the parent id of the node.
        /// @param nodeId The id for the node
        function getNodeParent(bytes32 nodeId) constant returns (bytes32) {
            return GroveLib.getNodeParent(index_lookup[node_to_index[nodeId]], nodeId);
        }

        /// @dev Retrieve the left child id of the node.
        /// @param nodeId The id for the node
        function getNodeLeftChild(bytes32 nodeId) constant returns (bytes32) {
            return GroveLib.getNodeLeftChild(index_lookup[node_to_index[nodeId]], nodeId);
        }

        /// @dev Retrieve the right child id of the node.
        /// @param nodeId The id for the node
        function getNodeRightChild(bytes32 nodeId) constant returns (bytes32) {
            return GroveLib.getNodeRightChild(index_lookup[node_to_index[nodeId]], nodeId);
        }

        /** @dev Retrieve the id of the node that comes immediately before this
         *  one.  Returns 0x0 if there is no previous node.
         */
        /// @param nodeId The id for the node
        function getPreviousNode(bytes32 nodeId) constant returns (bytes32) {
            return GroveLib.getPreviousNode(index_lookup[node_to_index[nodeId]], nodeId);
        }

        /** @dev Retrieve the id of the node that comes immediately after this
         *  one.  Returns 0x0 if there is no previous node.
         */
        /// @param nodeId The id for the node
        function getNextNode(bytes32 nodeId) constant returns (bytes32) {
            return GroveLib.getNextNode(index_lookup[node_to_index[nodeId]], nodeId);
        }

        /** @dev Update or Insert a data element represented by the unique
         *  identifier `id` into the index.
         */
        /// @param indexName The human readable name for the index that the node should be upserted into.
        /// @param id The unique identifier that the index node represents.
        /// @param value The number which represents this data elements total ordering.
        function insert(bytes32 indexName, bytes32 id, int value) public {
                bytes32 indexId = computeIndexId(msg.sender, indexName);
                var index = index_lookup[indexId];

                if (index.name != indexName) {
                        // If this is a new index, store it's name and id
                        index.name = indexName;
                        index.id = indexId;
                }

                // Store the mapping from nodeId to the indexId
                node_to_index[computeNodeId(indexId, id)] = indexId;

                GroveLib.insert(index, id, value);
        }

        /// @dev Query whether a node exists within the specified index for the unique identifier.
        /// @param indexId The id for the index.
        /// @param id The unique identifier of the data element.
        function exists(bytes32 indexId, bytes32 id) constant returns (bool) {
            return GroveLib.exists(index_lookup[indexId], id);
        }

        /// @dev Remove the index node for the given unique identifier.
        /// @param indexName The name of the index.
        /// @param id The unique identifier of the data element.
        function remove(bytes32 indexName, bytes32 id) public {
            GroveLib.remove(index_lookup[computeIndexId(msg.sender, indexName)], id);
        }

        /** @dev Query the index for the edge-most node that satisfies the
         * given query.  For >, >=, and ==, this will be the left-most node
         * that satisfies the comparison.  For < and <= this will be the
         * right-most node that satisfies the comparison.
         */
        /// @param indexId The id of the index that should be queried
        /** @param operator One of '>', '>=', '<', '<=', '==' to specify what
         *  type of comparison operator should be used.
         */
        function query(bytes32 indexId, bytes2 operator, int value) public returns (bytes32) {
                return GroveLib.query(index_lookup[indexId], operator, value);
        }
}
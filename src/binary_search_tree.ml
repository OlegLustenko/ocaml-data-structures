module type Ord = sig
  type t
  val compare : t -> t -> int
  val show : t -> string
end

module type BST = sig
  type t
  type comparable
  val empty_tree : t
  val insert : t -> comparable -> t

  (* Generated *)
  val find : t -> comparable -> bool
  val height : t -> int
  val string_of_tree : t -> string
end

module type S = sig
  (* Pass-thru *)
  type t
  type comparable
  val empty_tree : t
  val insert : t -> comparable -> t

  val left: t -> t
  val right: t -> t
  val value: t -> comparable
  (* Can I include this from the Ord sig? *)
  val show_value: comparable -> string
  val compare: comparable -> comparable -> int
end

module Make(Base: S) : (BST with type comparable := Base.comparable) = struct
  include Base

  let rec find node v =
    if node = Base.empty_tree then false
    else if Base.compare v (Base.value node) = 0 then true
    else if Base.compare v (Base.value node) < 0 then
      find (Base.left node) v
    else
      find (Base.right node) v

  let rec height node =
    if node = Base.empty_tree then 0
    else
      let left_height = height (Base.left node) in
      let right_height = height (Base.right node) in
      if left_height > right_height then 1 + left_height
      else 1 + right_height

  let rec string_of_tree node =
    if node = Base.empty_tree then "_"
    else
      "("
      ^ (Base.show_value @@ value node)
      ^ ", "
      ^ (string_of_tree @@ left node)
      ^ ", "
      ^ (string_of_tree @@ right node)
      ^ ")"
end

module BinarySearchTree(Ord : Ord) : (BST with type comparable := Ord.t) =
  Make(struct
    type t =
      | Empty
      | Node of { value: Ord.t;
                  left: t;
                  right: t;
                }

    type comparable = Ord.t
    let show_value = Ord.show

    let empty_tree = Empty

    let rec insert node value = match node with
      | Empty -> Node { value = value;
                        left = Empty;
                        right = Empty;
                      }
      | Node n ->
        if Ord.compare value n.value < 0
        then
          Node { n with
                 left = insert n.left value }
        else
          Node { n with
                 right = insert n.right value }

    let left (Node n) = n.left
    let right (Node n) = n.right
    let value (Node n) = n.value
    let compare = Ord.compare
  end)

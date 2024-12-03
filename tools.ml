(* Copyright (c) 2024 Max Charrier, Inès Schneider. All Rights Reserved. *)

#require "cryptokit"
#require "base64"

open List

let read_datafile (df : string) : (string * string) list * int =
	let ic = open_in df in
	let rec aux acc c =
		try
			(* first line is for the username, second is for the password *)
			(* and it repeats *)
			let username = input_line ic in
			let password = input_line ic in
			(* construct the list with credential *)
			aux ((username, password)::acc) (c+1)
		with End_of_file -> close_in ic;
		(* preserve file order *)
		(List.rev acc, c)
	in
	aux [] 0

let read_wordlist (wl : string) : string list =
	let ic = open_in wl in
	let rec aux acc =
		try
			(* each line contains one and only one word *)
			let word = input_line ic in
			(* construct the list with readed word *)
			aux (word::acc)
		with End_of_file -> close_in ic;
		acc
	in
	aux []

let hash_password (pw : string) : string =
	(* encrypt password with sha2-256 and base64 encoding (rfc 4648 *)
	Base64.encode_exn (Cryptokit.hash_string (Cryptokit.Hash.sha256 ()) pw)

let encrypt_wordlist (wl : string list) : string list =
	let rec aux acc lst =
		if lst = [] then acc
		(* construct the list with password hashes *)
		else aux (hash_password (hd lst)::acc) (tl lst)
	in
	aux [] wl

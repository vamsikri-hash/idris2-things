module Enigma 
import Data.Vect


isUppercase:  Char -> Bool 
isUppercase c = if (c == toUpper c) then True else False

uppercase : Char -> Type
uppercase c = c = toUpper c

-- Uninhabited (uppercase 'A') where
--   uninhabited Refl impossible

-- Try to comstruct data type data IUSc : Char -> Type 
                                  -- IA -> IUSC a

uppercaseEncoderWithProof : (u : Char) -> Dec (uppercase u)
uppercaseEncoderWithProof u =
  case u of
    'A' => Yes Refl
    'B' => Yes Refl
    'C' => Yes Refl
    'D' => Yes Refl
    'E' => Yes Refl
    'F' => Yes Refl
    'G' => Yes Refl
    'H' => Yes Refl
    'I' => Yes Refl
    'J' => Yes Refl
    'K' => Yes Refl
    'L' => Yes Refl
    'M' => Yes Refl
    'N' => Yes Refl
    'O' => Yes Refl
    'P' => Yes Refl
    'Q' => Yes Refl
    'R' => Yes Refl
    'S' => Yes Refl
    'T' => Yes Refl
    'U' => Yes Refl
    'V' => Yes Refl
    'W' => Yes Refl
    'X' => Yes Refl
    'Y' => Yes Refl
    'Z' => Yes Refl
    t => No ?kk


allUppercase: (l: List Char) -> List ((c : Char ** ((isUppercase c) = True)) ) 
allUppercase [] = []
allUppercase (x :: xs) = (uppercaseEncoderWithProof x) :: allUppercase xs

getCharListFromAllUppercase: List ((c : Char ** ((isUppercase c) = True)) ) -> List Char 
getCharListFromAllUppercase [] = []
getCharListFromAllUppercase (((fst ** snd)) :: xs) = fst :: (getCharListFromAllUppercase xs)


data AllUppercase : List Char -> Type where
  NilAU : AllUppercase []
  ConsAU : {x : Char} -> {xs : List Char} -> isUppercase x = True -> AllUppercase xs -> AllUppercase (x :: xs)

  
allUppercaseList: (l: List ((c : Char ** (isUppercase c = True))) ) -> (AllUppercase (getCharListFromAllUppercase l))
allUppercaseList [] = NilAU
allUppercaseList (((fst ** snd)) :: xs) = ConsAU snd (allUppercaseList xs)


-- Program starts -- 

-- isBetween: (x: Int) -> ((x >= 0 && x <= 26) = True)
-- isBetween x = ?isBetween_rhs

-- index: (c: Char) -> {auto p: (isUppercase c) = True} -> (x: Int ** ((x >= 0 && x <= 26) = True)) 
-- index c = let t = cast c - cast 'A' in (t ** ?lk)

index: (c: Char) -> {auto p: (isUppercase c) = True} -> Int
index c = cast c - cast 'A' 

charToIndex:  (l: List Char) -> {auto uppercaseList: AllUppercase l} -> List Int
charToIndex [] = []
charToIndex (x :: xs) {uppercaseList = ConsAU a b} = index x :: (charToIndex xs)

getVal: Ord a => (key: a) -> (List (a, b)) -> Maybe b
getVal key [] = Nothing
getVal key ((k, v) :: xs) = if key == k then Just v else getVal key xs

mapi: (f: Int -> a -> b) -> List a -> List b 
mapi f ls = mapiaux f ls 0 where 
            mapiaux: (f: Int -> a -> b) -> List a -> Int -> List b 
            mapiaux f [] i = []
            mapiaux f (x :: xs) i = (f i x) :: (mapiaux f xs (i+1))

makeSpecMap: (wiring: List Char) -> {auto uppercaseList: AllUppercase wiring} -> List (Int, Int)
makeSpecMap wiring = mapi (\i, x  => (i, x)) $ charToIndex wiring

data Mode = RightToLeft | LeftToRight


mapFrom : Mode -> (wiring: List Char) -> {auto uppercaseList: AllUppercase wiring} -> 
          (topLetter: Char) -> {auto uppercase: isUppercase topLetter = True} -> Int -> Maybe Int
mapFrom mode wiring topLetter inputPos = 
        let specificationMap = makeSpecMap wiring
            topLetterIndex = index topLetter
            forwardOffset: Int -> Int -> Int
            forwardOffset offset input = mod (offset + input)  26
            inputContact = forwardOffset topLetterIndex inputPos
            backWardOffset: Int -> Int -> Int
            backWardOffset offset input = mod (26 - offset + input) 26
            outputContact: Mode -> Maybe Int
            outputContact mode = case mode of 
                                 RightToLeft => getVal inputContact specificationMap
                                 LeftToRight => getVal inputContact $ map (\(a, b) => (b, a)) specificationMap
        in case outputContact mode of 
                Just v => Just $ backWardOffset topLetterIndex v
                Nothing => Nothing

mapRefl: (wiring: List Char) -> {auto uppercaseList: AllUppercase wiring} -> Int -> Maybe Int
mapRefl wiring i = getVal i $ makeSpecMap wiring



isValidChar: Char -> Bool
isValidChar c = toUpper c >= 'A' && toUpper c <= 'Z' 


isValidList: List Char -> Bool
isValidList [] = True
isValidList (x :: xs) = (isValidChar x) && (isValidList xs)

program: String -> Char -> Int -> Maybe Int
program cs topLetter pos = 
          let cis = unpack cs in 
          if (isValidList cis && isValidChar topLetter) then
            let ws = (allUppercase cis)
                (topLetter **  p) = (uppercaseEncoderWithProof topLetter)
                ks = (mapFrom LeftToRight  (getCharListFromAllUppercase ws) {uppercaseList = allUppercaseList ws} topLetter pos)
            in ks
          else Nothing


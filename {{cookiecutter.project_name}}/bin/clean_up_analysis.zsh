#!/usr/bin/zsh

##### Figures

# Set up the archive
FIG_ARCHIVE='archive/figure'
if [[ -e ${FIG_ARCHIVE} && ( ! -d ${FIG_ARCHIVE} ) ]]
then
	print -u 2 "${FIG_ARCHIVE} is not a directory!"
	exit 1
fi

if [[ ! -e ${FIG_ARCHIVE} ]]
then
	mkdir -p ${FIG_ARCHIVE}
fi

# NOTE: May need to use =( instead of <( here. Not sure if comm needs to seek backwards
comm -23 \
	 <( grep -h '^image::' *asciidoc | sed -e 's/image:://' -e 's/\[.*//' | sort | uniq ) \
	 <( ls figure/* | sort ) \
	 | xargs -d '\n' -r mv -t ${FIG_ARCHIVE}

##### Cache

# Get obsolete cache
CACHE_USED=$(mktemp)
CACHE_USED_SORT=$(mktemp)
CACHE_ALL=$(mktemp)

setopt "EXTENDED_GLOB"			# Allows case-insensitive matching
RAFILES=((#i)*.Rasciidoc(.))

for RAFILE in ${RAFILES}
do
	# print "File: ${RAFILE}"
	CACHE_PFX=$(echo ${RAFILE} | sed 's/\..*//')
	BLOCK_NAMES=( $(awk '/begin\.rcode/ {print $2}' ${RAFILE} | sed 's/,$//' ) )
	for BLOCK in ${BLOCK_NAMES}
	do
		CACHES=( cache/${CACHE_PFX}_${BLOCK}_*(N.) )
		if (( ${#CACHES} > 0 ))
		then
			print -l ${CACHES} >> ${CACHE_USED}
		# else
		# 	print -l "No caches for ${RAFILE}_${BLOCK}"
		fi
	done
done

comm -23 \
	 <( ls cache/* | sort ) \
	 <( sort ${CACHE_USED} ) \
	 | xargs -d '\n' -r rm


# sort ${CACHE_USED} > ${CACHE_USED_SORT}
# ls cache/* | sort > ${CACHE_ALL}

# CACHE_OLD=( ${(f)"$(comm -23 ${CACHE_ALL} ${CACHE_USED_SORT})"} )

# # Do the deletion
# for CACHE in ${CACHE_OLD}
# do
# 	# print -l "deleting ${CACHE}"
# 	rm ${CACHE}
# done

# Cleanup
rm ${CACHE_USED} # ${CACHE_USED_SORT} ${CACHE_ALL}

##### Data

# Set up the archive
DATA_ARCHIVE='archive/data'
if [[ -e ${DATA_ARCHIVE} && ( ! -d ${DATA_ARCHIVE} ) ]]
then
	print -u 2 "${DATA_ARCHIVE} is not a directory!"
	exit 1
fi

if [[ ! -e ${DATA_ARCHIVE} ]]
then
	mkdir -p ${DATA_ARCHIVE}
fi

rm -f data/*~(N) data/\#*(N)				# Get rid of emacs garbage
DATA_ALL=( data/* ) 
for DFILE in ${DATA_ALL}
do
	# We don't want to remove things where we've changed the format so
	# search on the filename without the extension
	DPAT=$(echo ${DFILE} | sed -r -e 's|^data/||' -e 's/\.[A-Za-z]{3,4}$//')
	FOUND_DATA=( $(grep -l ${DPAT} *R) )
	if (( ${#FOUND_DATA} == 0 ))
	then
		git mv ${DFILE} ${DATA_ARCHIVE}
	fi
done


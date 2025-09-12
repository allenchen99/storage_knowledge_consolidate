
cal ZFS filesystems that will have snapshot logic applied
DATASETS="mypool/data \
	          mypool/media \
		            mypool/cloud"

# Destination host for snapshot replication
DHOST=hostB

# Output logfile
LOGFILE=/var/log/snapxfer.log

# Tools that help implement snapshot logic and transfer
ZSNAP=/opt/local/sbin/zfSnap
ZXFER=/opt/local/sbin/zxfer

######################################################################
# Main logic                                                         #
######################################################################

interval=$1

usage() {
	    if [ "X${interval}" = "X" ]; then
		            echo ""
			            echo "Usage: $0 <interval> (async|hourly|daily|weekly|purge)"
				            echo ""
					            echo "* Asynchronous DR snapshots are kept for 1 hour"
						            echo "* Hourly snapshots are kept for 1 day"
							            echo "* Daily snapshots are kept for one week"
								            echo "* Weekly snapshots are kept for one month"
									            echo ""
										            exit 1
											        fi
											}

											# Ensure log file exists
											if [ ! -f "$LOGFILE" ]; then
												    touch "$LOGFILE"
											fi

											case "${interval}" in
												    'async')
													            # Take snapshots for asynchronous DR purposes
														            for dset in $DATASETS; do
																                $ZSNAP -v -s -S -a 1h "$dset" >> "$LOGFILE"
																		        done

																			        # Send snapshots to failover host
																				        for dset in $DATASETS; do
																						            $ZXFER -dFv -T root@"$DHOST" -N "$dset" zroot >> "$LOGFILE"
																							            done

																								            echo "" >> "$LOGFILE"
																									            ;;
																										        'hourly')
																												        # Take snapshots, keep for one day
																													        for dset in $DATASETS; do
																															            $ZSNAP -s -S -a 1d "$dset" >> "$LOGFILE"
																																            done
																																	            echo "" >> "$LOGFILE"
																																		            ;;
																																			        'daily')
																																					        # Take snapshots, keep for one week
																																						        for dset in $DATASETS; do
																																								            $ZSNAP -s -S -a 1w "$dset" >> "$LOGFILE"
																																									            done

																																										            # Purge snapshots according to TTL
																																											            $ZSNAP -s -S -d >> "$LOGFILE"
																																												            echo "" >> "$LOGFILE"
																																													            ;;
																																														        'weekly')
																																																        # Take snapshots, keep for one month
																																																	        for dset in $DATASETS; do
																																																			            $ZSNAP -s -S -a 1m "$dset" >> "$LOGFILE"
																																																				            done
																																																					            echo "" >> "$LOGFILE"
																																																						            ;;
																																																							        'purge')
																																																									        # Purge snapshots according to TTL
																																																										        $ZSNAP -v -s -S -d
																																																											        ;;
																																																												    *)
																																																													            usage
																																																														            ;;
																																																													    esac


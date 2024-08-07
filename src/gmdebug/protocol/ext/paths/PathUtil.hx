package gmdebug.protocol.ext.paths;

import haxe.io.Path as HxPath;
import gmdebug.protocol.ext.paths.Paths.PATH_CLIENT_READY;
import gmdebug.protocol.ext.paths.Paths.PATH_OUTPUT;
import gmdebug.protocol.ext.paths.Paths.PATH_INPUT;
import gmdebug.protocol.ext.paths.Paths.PATH_PIPES_READY;
import gmdebug.protocol.ext.paths.Paths.PATH_CLIENT_ACK;
import gmdebug.protocol.ext.paths.Paths.PATH_CONNECTION;
import gmdebug.protocol.ext.paths.Paths.PATH_CONNECTION_IN_PROGRESS;
import gmdebug.protocol.ext.paths.Paths.PATH_SINGULAR_PIPE;
import gmdebug.protocol.ext.paths.Paths.PATH_HANDSHAKE_CLIENT;
import gmdebug.protocol.ext.paths.Paths.PATH_HANDSHAKE_SERVER;
import gmdebug.protocol.ext.paths.Paths.PATH_HANDSHAKE_FOLDER;
import gmdebug.protocol.ext.paths.Paths.PATH_PIPE_FOLDERS;
import gmdebug.protocol.ext.paths.Paths.PATH_CONNECTION_AQUIRED;
import gmdebug.protocol.ext.paths.Paths.PATH_DATA;


function generatePipeLocations(dataLocations:DataLocations, ourfolder:String):PipeLocations {
	var folder = HxPath.join([dataLocations.pipelocationsfolder, ourfolder]);
	return {
		folder: folder,
		client_ready: HxPath.join([folder, PATH_CLIENT_READY]),
		output: HxPath.join([folder, PATH_OUTPUT]),
		input: HxPath.join([folder, PATH_INPUT]),
		pipes_ready: HxPath.join([folder, PATH_PIPES_READY]),
		client_ack: HxPath.join([folder, PATH_CLIENT_ACK]),
		connect: HxPath.join([folder, PATH_CONNECTION]),
		connection_in_progress: HxPath.join([folder, PATH_CONNECTION_IN_PROGRESS]),
		connection_aquired: HxPath.join([folder, PATH_CONNECTION_AQUIRED]),
	}
}

function generatePipeLocationsWithID(datalocations:DataLocations, id:String):PipeLocations {
	var generatedPipeFolder = '$PATH_SINGULAR_PIPE$id';
	return generatePipeLocations(datalocations, generatedPipeFolder);
}

function generateHandshakeLocations(datafolder:String):HandshakeLocations {
	var folder = HxPath.join([datafolder, PATH_HANDSHAKE_FOLDER]);
	return {
		folder: folder,
		pre_path_client_handshake: HxPath.join([folder, PATH_HANDSHAKE_CLIENT]),
		pre_path_server_handshake: HxPath.join([folder, PATH_HANDSHAKE_SERVER]),
	}
}

function generateDataLocations(folder:String):DataLocations {
	var datafolder = HxPath.join([folder, PATH_DATA]);
	return {
		folder: datafolder,
		pipelocationsfolder: HxPath.join([datafolder, PATH_PIPE_FOLDERS]),
		handshakelocations: generateHandshakeLocations(datafolder),
	}
}

function generateDataLocationsForLua():DataLocations {
	return {
		folder: "",
		pipelocationsfolder: PATH_PIPE_FOLDERS,
		handshakelocations: generateHandshakeLocations(""),
	}
}